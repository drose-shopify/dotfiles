# frozen_string_literal: true

require_relative 'shopify_tasks'
require 'yaml'
require 'csv'
require 'bigdecimal'
require 'net/ftp'
require 'zip'

module TaxUtils
  module_function

  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  def self.string_to_bool(data)
    return data if !!data == data
    return true if data.casecmp('y').zero? || data.casecmp('true').zero?

    false
  end

  def configure_betas(obj:, features:)
    features.each do |feature|
      if feature[:state] == :enable
        next if obj.beta.enabled?(feature[:feature])

        puts "Enabling [#{feature[:feature]}]"
        obj.beta.enable(feature[:feature])
      elsif feature[:state] == :disable
        next if obj.beta.disabled?(feature[:feature])

        puts "Disabling [#{feature[:feature]}]"
        obj.beta.disable(feature[:feature])
      end
    end
  end

  def rate_row_equal?(old_row, new_row)
    return false unless BigDecimal(old_row.state_sales_tax, 8) == BigDecimal(new_row.state_sales_tax, 8)
    return false unless BigDecimal(old_row.county_sales_tax, 8) == BigDecimal(new_row.county_sales_tax, 8)
    return false unless BigDecimal(old_row.city_sales_tax, 8) == BigDecimal(new_row.city_sales_tax, 8)
    return false unless old_row.tax_shipping_alone == new_row.tax_shipping_alone
    return false unless old_row.tax_shipping_and_handling_together == new_row.tax_shipping_and_handling_together

    true
  end

  def create_row(tax_rate)
    tax_rate.total_sales_tax = tax_rate.state_sales_tax + tax_rate.county_sales_tax + tax_rate.city_sales_tax
    [
      tax_rate.zip_code,
      tax_rate.state_abbrev.upcase,
      tax_rate.county_name.upcase,
      tax_rate.city_name.upcase,
      tax_rate.state_sales_tax,
      tax_rate.county_sales_tax,
      tax_rate.city_sales_tax,
      tax_rate.total_sales_tax,
      if tax_rate.tax_shipping_alone
        'Y'
      else
        'N'
      end,
      if tax_rate.tax_shipping_and_handling_together
        'Y'
      else
        'N'
      end
    ]
  end

  namespace :taxes do
    desc 'Enables all tax betas'
    task enable_edge: [:environment] do
      beta_flags = YAML.load_file('/Users/davidrose/dotfiles/rake_global/beta_flags.yml').with_indifferent_access

      beta_flags[:api_clients].each_pair do |app_handle, flags|
        app_client = ApiClient.find_by(handle: app_handle)
        configure_betas(
          obj: app_client,
          features: flags.map do |flag|
            {
              feature: flag,
              state: :enable
            }
          end
        )
      end

      configure_betas(
        obj: shop_from_env,
        features: beta_flags[:shop_betas].map do |flag|
          {
            feature: flag,
            state: :enable
          }
        end
      )
    end

    desc 'Sets shop into canada migration state'
    task canada_migration: [:environment] do
      puts 'Deleting all tax registrations'
      Shop.tax_registrations.destroy_all

      shop_betas = [
        {
          feature: 'tax_enable_migration_flow',
          state: :enable
        }, {
          feature: 'tax_migration_exclusion',
          state: :disable
        }, {
          feature: 'use_active_tax_engine',
          state: :disable
        }
      ]

      configure_betas(obj: shop_from_env, features: shop_betas)
    end

    desc 'Verifies a rate file with the usa_tax_rate table'
    task verify_rates: [:environment] do
      file_path = ENV['TAX_RATE_FILE']
      raise 'File path to the tax rate file is required' unless file_path

      tax_rates = CSV.table(file_path)

      errors_by_zip = {}
      tax_rates.each do |new_rate|
        current_rate = ::USATaxRate.find_by(zip_code: new_rate[:zip_code])
        if current_rate.blank?
          puts "usa_tax_rate table is missing zipcode: #{new_rate[:zip_code]}"
          next
        end

        new_rate[:tax_shipping_alone] = TaxUtils.string_to_bool(new_rate[:tax_shipping_alone])
        new_rate[:tax_shipping_and_handling_together] = TaxUtils.string_to_bool(new_rate[:tax_shipping_and_handling_together])

        errors = []
        new_rate.headers.each do |column|
          next if column == :zip_code

          new_data = new_rate[column]
          current_data = current_rate[column]

          if new_data.is_a?(Numeric)
            new_data = BigDecimal(new_data, 8)
            current_data = BigDecimal(current_data, 8)
          end
          if new_data != current_data
            errors << "#{column} does not match databse. (DB Value: #{current_data}, expected: #{new_data}"
          end
        end

        errors_by_zip[new_rate[:zip_code]] = errors unless errors.empty?
      end

      unless errors_by_zip.empty?
        errors_by_zip.each do |zip, errors|
          puts "#{zip} has mismatched data"
          errors.each { |error| puts "\t#{error}" }
          puts "\n"
        end
      end
    end

    desc 'Determine differences in total sales tax rate'
    task determine_rate_differences: [:environment] do
      rate_file = ENV['TAX_RATE_FILE']
      output_file = ENV['OUTPUT_FILE'] || 'rate_difference.csv'

      output_rows = []

      output = CSV.open(output_file, 'w')
      output << %w[zip_code difference state_sales_tax_old state_sales_tax_new county_sales_tax_old county_sales_tax_new city_sales_tax_old city_sales_tax_new total_sales_tax_old total_sales_tax_new]
      CSV.foreach(rate_file, headers: true) do |row|
        old_row = ::USATaxRate.find_by(zip_code: row['zip_code'])

        output_rows << {
          zip_code: old_row.zip_code,
          difference: old_row.total_sales_tax.to_d - row['total_sales_tax'].to_d,
          state_sales_tax_old: old_row.state_sales_tax,
          state_sales_tax_new: row['state_sales_tax'],
          county_sales_tax_old: old_row.county_sales_tax,
          county_sales_tax_new: row['county_sales_tax'],
          city_sales_tax_old: old_row.city_sales_tax,
          city_sales_tax_new: row['city_sales_tax'],
          total_sales_tax_old: old_row.total_sales_tax,
          total_sales_tax_new: row['total_sales_tax']
        }
      end

      output_rows
        .sort_by { |row| row[:difference] }
        .reverse_each do |row|
          output << row.values
        end
      output.close
    end

    desc 'Imports all delta files'
    task reimport_deltas: [:environment] do
      puts "Deleting all entries in usa_tax_rates"
      ::USATaxRate.destroy_all

      puts "Running import on base file #{::USATaxRate::Importer::USA_RATE_FILE_PATH}"
      ::USATaxRate::Importer.run

      sorted_deltas = Dir["db/avalara/delta*.csv"].sort_by do |filepath|
        filename = File.basename(filepath, '.csv')
        file_date_parts = filename.sub(/^delta_?/, '').split('_')
        file_date = Time.parse(file_date_parts.join(' '))
      end

      sorted_deltas.each do |delta_filepath|
        puts "Running import on delta #{File.basename(delta_filepath, '.csv')}"
        ::USATaxRate::Importer.importdelta(delta_filepath)
      end
    end

    desc 'Fixes California'
    task fix_california: [:environment] do
      county_taxes = {
        'ALAMEDA': 2,
        'AMADOR': 0.5,
        'CONTRA COSTA': 1,
        'DEL NORTE': 0.25,
        'FRESNO': 0.725,
        'HUMBOLDT': 0.5,
        'IMPERIAL': 0.5,
        'INYO': 0.5,
        'LOS ANGELES': 2.25,
        'MADERA': 0.5,
        'MARIN': 1,
        'MARIPOSA': 0.5,
        'MENDOCINO': 0.625,
        'MERCED': 0.5,
        'MONTEREY': 0.5,
        'NAPA': 0.5,
        'NEVADA': 0.25,
        'ORANGE': 0.5,
        'RIVERSIDE': 0.5,
        'SACRAMENTO': 0.5,
        'SAN BENITO': 1,
        'SAN BERNARDINO': 0.5,
        'SAN DIEGO': 0.5,
        'SAN JOAQUIN': 0.5,
        'SAN MATEO': 2,
        'SANTA BARBARA': 0.5,
        'SANTA CLARA': 1.75,
        'SANTA CRUZ': 1.75,
        'SOLANO': 0.125,
        'SONOMA': 1,
        'STANISLAUS': 0.625,
        'TULARE': 0.5,
        'YUBA': 1
      }.with_indifferent_access
      delta_file_name = ENV['OUTPUT_FILE'] || "db/avalara/delta_#{Date.today.strftime('%b_%d_%Y').downcase}.csv"

      revert_csv = CSV.open(File.join(File.dirname(delta_file_name), "revert_#{File.basename(delta_file_name)}"), 'w')
      delta_csv = CSV.open(delta_file_name, 'w')

      revert_csv << %w[zip_code state_abbrev county_name city_name state_sales_tax county_sales_tax city_sales_tax total_sales_tax tax_shipping_alone tax_shipping_and_handling_together]
      delta_csv << %w[zip_code state_abbrev county_name city_name state_sales_tax county_sales_tax city_sales_tax total_sales_tax tax_shipping_alone tax_shipping_and_handling_together]
      ::USATaxRate.where(state_abbrev: 'CA').each do |rate_row|
        next unless county_taxes.key?(rate_row.county_name)

        state_tax = rate_row.state_sales_tax.to_d
        county_tax = county_taxes[rate_row.county_name].to_d / 100.to_d
        city_tax = rate_row.total_sales_tax.to_d - (state_tax + county_tax)

        next if city_tax < 0
        next if county_tax < 0

        new_rate = rate_row.dup
        new_rate.state_sales_tax = state_tax
        new_rate.county_sales_tax = county_tax
        new_rate.city_sales_tax = city_tax
        next if rate_row_equal?(rate_row, new_rate)

        delta_csv << create_row(new_rate)
        revert_csv << create_row(rate_row)
      end
      revert_csv.close
      delta_csv.close
    end

    desc 'Generates a tax rate delta from yaml file'
    task generate_rate_update: [:environment] do
      rate_file = ENV['TAX_RATE_FILE'] || '/Users/davidrose/dotfiles/rake_global/tax_rates_july.yml'
      output_file = ENV['OUTPUT_FILE'] || 'delta_tax_rate.csv'

      rates = YAML.load_file(rate_file)
      rates = rates.with_indifferent_access

      revert_csv = CSV.open(File.join(File.dirname(output_file), "revert_#{File.basename(output_file)}"), 'w')
      delta_csv = CSV.open(output_file, 'w')
      begin
        revert_csv << %w[zip_code state_abbrev county_name city_name state_sales_tax county_sales_tax city_sales_tax total_sales_tax tax_shipping_alone tax_shipping_and_handling_together]
        delta_csv << %w[zip_code state_abbrev county_name city_name state_sales_tax county_sales_tax city_sales_tax total_sales_tax tax_shipping_alone tax_shipping_and_handling_together]
        rates.each do |state, state_info|
          state_data = ::USATaxRate.where(state_abbrev: state.upcase)
          state_data.each do |old_rate|
            new_rate = old_rate.dup

            county_info = state_info.dig(:counties, old_rate.county_name.upcase)
            city_info = state_info.dig(:counties, old_rate.county_name.upcase, :cities, old_rate.city_name.upcase)

            new_rate.state_sales_tax = BigDecimal(state_info[:rate], 7) / 100.0 if state_info.key?(:rate)

            if county_info.present?
              new_rate.county_sales_tax = BigDecimal(county_info[:rate], 7) / 100.0 if county_info.key?(:rate)
            end

            if city_info.present?
              new_rate.city_sales_tax = BigDecimal(city_info[:rate], 7) / 100.0 if city_info.key?(:rate)
              new_rate.county_sales_tax = BigDecimal(city_info[:county_rate], 7) / 100.0 if city_info.key?(:county_rate)
            end

            next if rate_row_equal?(old_rate, new_rate)

            delta_csv << create_row(new_rate)
            revert_csv << create_row(old_rate)
          end
        end
      ensure
        revert_csv.close
        delta_csv.close
      end
    end
  end
end
