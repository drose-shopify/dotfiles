# frozen_string_literal: true
require_relative 'shopify_tasks'
require 'yaml'
require 'csv'
require 'bigdecimal'

module TaxUtils
  extend self
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
  return true
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
    desc "Enables all tax betas"
    task enable_edge: [:environment] do
      app_handle = ENV['APP_HANDLE'] || 'shopify-web'
      app_client = ApiClient.find_by(handle: app_handle)

      api_betas = [
        {
          feature: 'tax_exemptions_for_customer',
          state: :enable,
        }, {
          feature: 'tax_overrides_api',
          state: :enable,
        }
      ]

      shop_betas = [
        {
          feature: 'use_active_tax_engine',
          state: :enable,
        }, {
          feature: 'customer_tax_exemptions',
          state: :enable,
        }
      ]

      configure_betas(obj: app_client, features: api_betas)
      configure_betas(obj: shop_from_env, features: shop_betas)
    end

    desc "Sets shop into canada migration state"
    task canada_migration: [:environment] do
      puts "Deleting all tax registrations"
      Shop.tax_registrations.destroy_all

      shop_betas = [
        {
          feature: 'tax_enable_migration_flow',
          state: :enable,
        }, {
          feature: 'tax_migration_exclusion',
          state: :disable,
        }, {
          feature: 'use_active_tax_engine',
          state: :disable,
        },
      ]

      configure_betas(obj: shop_from_env, features: shop_betas)
    end

    desc "Verifies a rate file with the usa_tax_rate table"
    task verify_rates: [:environment] do
      file_path = ENV['TAX_RATE_FILE']
      raise "File path to the tax rate file is required" unless file_path

      tax_rates = CSV.table(file_path)

      errors_by_zip = {}
      tax_rates.each do |new_rate|
        current_rate = ::USATaxRate.find_by(zip_code: new_rate[:zip_code])
        if current_rate.blank?
          puts "usa_tax_rate table is missing zipcode: #{new_rate[:zip_code]}"
          next
        end

        new_rate[:tax_shipping_alone] = TaxUtils::string_to_bool(new_rate[:tax_shipping_alone])
        new_rate[:tax_shipping_and_handling_together] = TaxUtils::string_to_bool(new_rate[:tax_shipping_and_handling_together])

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

        errors_by_zip[new_rate[:zip_code]] = errors if errors.length > 0
      end

      unless errors_by_zip.empty?
        errors_by_zip.each do |zip, errors|
          puts "#{zip} has mismatched data"
          errors.each {|error| puts "\t#{error}"}
          puts "\n"
        end
      end
    end

    desc "Generates a tax rate delta from yaml file"
    task generate_rate_update: [:environment] do
      rate_file = ENV['TAX_RATE_FILE'] || '/Users/davidrose/dotfiles/rake_global/tax_rates_july.yml'
      output_file = ENV['OUTPUT_FILE'] || 'delta_tax_rate.csv'

      rates = YAML.load_file(rate_file)
      rates = rates.with_indifferent_access

      revert_csv = CSV.open(File.join(File.dirname(output_file), "revert_#{File.basename(output_file)}"), 'w')
      delta_csv = CSV.open(output_file, 'w')
      begin
        revert_csv << ['zip_code','state_abbrev','county_name','city_name','state_sales_tax','county_sales_tax','city_sales_tax','total_sales_tax','tax_shipping_alone','tax_shipping_and_handling_together']
        delta_csv << ['zip_code','state_abbrev','county_name','city_name','state_sales_tax','county_sales_tax','city_sales_tax','total_sales_tax','tax_shipping_alone','tax_shipping_and_handling_together']
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

  desc "updates the usa_tax_rate db from onesource db"
  task update_tax_rates: [:environment] do
    rate_db = '/Users/davidrose/Downloads/AS_zip4/zip5.csv'
    error_file = '/Users/davidrose/Downloads/AS_zip4/mismatch.txt'
    file = File.open(error_file, 'w')
    CSV.foreach(rate_db, headers: true) do |row|
      shopify_rate = ::USATaxRate.find_by(zip_code: row['ZIP_CODE'].to_s)
      if shopify_rate.blank?
        puts "No entry for #{row['ZIP_CODE']}\n"
        next
      end

      errors = []
      if shopify_rate.state_abbrev != row['STATE_ABBREV']
        errors << "STATE: #{shopify_rate.state_abbrev} != #{row['STATE_ABBREV']}"
      end
      if shopify_rate.county_name != row['COUNTY_NAME']
        errors << "COUNTY: #{shopify_rate.county_name} != #{row['COUNTY_NAME']}"
      end
      if shopify_rate.city_name != row['CITY_NAME']
        errors << "CITY: #{shopify_rate.city_name} != #{row['CITY_NAME']}"
      end

      next if errors.empty?

      file.puts "#{shopify_rate.zip_code} - #{errors.join(',')}"
    end
  end
end
