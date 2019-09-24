# frozen_string_literal: true
require_relative 'shopify_tasks'
require 'yaml'
require 'csv'
require 'bigdecimal'
require 'net/ftp'
require 'zip'

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
  return false unless bigdecimal(old_row.state_sales_tax, 8) == bigdecimal(new_row.state_sales_tax, 8)
  return false unless bigdecimal(old_row.county_sales_tax, 8) == bigdecimal(new_row.county_sales_tax, 8)
  return false unless bigdecimal(old_row.city_sales_tax, 8) == bigdecimal(new_row.city_sales_tax, 8)
  return false unless old_row.tax_shipping_alone == new_row.tax_shipping_alone
  return false unless old_row.tax_shipping_and_handling_together == new_row.tax_shipping_and_handling_together
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

    desc "Determine differences in total sales tax rate"
    task determine_rate_differences: [:environment] do
      rate_file = ENV['TAX_RATE_FILE']
      output_file = ENV['OUTPUT_FILE'] || 'rate_difference.csv'

      output_rows = []

      output = CSV.open(output_file, 'w')
      output << ["zip_code","difference","state_sales_tax_old","state_sales_tax_new","county_sales_tax_old","county_sales_tax_new","city_sales_tax_old","city_sales_tax_new","total_sales_tax_old","total_sales_tax_new"]
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
  task update_tax_rates_old: [:environment] do
    rate_db_file = nil
    Net::FTP.open('ftp.taxdatasystems.com') do |ftp|
      ftp.login('shopify1','shopify99')
      beginning_of_month = Date.today - Date.today.mday + 1
      ftp.nlst.each do |filename|
        if ftp.mtime(filename).to_date >= Date.today
          ftp.getbinaryfile(filename)
          rate_db_file = filename
          return
        end
      end
      rate_db_file = 'AS_zip4.zip'
      puts "Downloading #{rate_db_file}" unless rate_db_file.nil?
      ftp.getbinaryfile(rate_db_file) unless rate_db_file.nil?
    end

    if rate_db_file.nil?
      puts "No new rate file found"
      return
    end

    puts "Extracting zip"
    Zip::File.open(rate_db_file) do |zip_file|
      entry = zip_file.glob("#{File.basename(rate_db_file, '.*')}.txt").first
      entry.extract('rate_file.txt')
    end

    output_file = ENV['OUTPUT_FILE'] || 'delta_tax_rate.csv'
    rate_db = 'rate_file.txt'
    #rate_db = '/Users/davidrose/Downloads/AS_zip4/AS_zip4.txt'
    revert_csv = CSV.open(File.join(File.dirname(output_file), "revert_#{File.basename(output_file)}"), 'w')
    delta_csv = CSV.open(output_file, 'w')

    total_changes = 0

    begin
      revert_csv << ['zip_code','state_abbrev','county_name','city_name','state_sales_tax','county_sales_tax','city_sales_tax','total_sales_tax','tax_shipping_alone','tax_shipping_and_handling_together']
      delta_csv << ['zip_code','state_abbrev','county_name','city_name','state_sales_tax','county_sales_tax','city_sales_tax','total_sales_tax','tax_shipping_alone','tax_shipping_and_handling_together']
      puts "Reading file and checking for differences"
      CSV.foreach(rate_db, headers: true, col_sep: "\t") do |row|
        next unless row['RECORD_TYPE'] == 'Z'
        shopify_rate = ::USATaxRate.find_by(zip_code: row['ZIP_CODE'].to_s)
        if shopify_rate.blank?
          # puts "No entry for #{row['ZIP_CODE']}\n"
          next
        end

        state_rate = row['STATE_SALES_TAX'].to_d
        county_rate = row['COUNTY_SALES_TAX'].to_d
        city_rate = row['CITY_SALES_TAX'].to_d
        other_rates = row['MTA_SALES_TAX'].to_d +
          row['SPD_SALES_TAX'].to_d +
          row['OTHER1_SALES_TAX'].to_d +
          row['OTHER2_SALES_TAX'].to_d +
          row['OTHER3_SALES_TAX'].to_d +
          row['OTHER4_SALES_TAX'].to_d

        new_rate = shopify_rate.dup

        new_rate.state_sales_tax = state_rate
        new_rate.county_sales_tax = county_rate
        new_rate.city_sales_tax = city_rate + other_rates
        new_rate.total_sales_tax = state_rate + county_rate + city_rate + other_rates
        new_rate.tax_shipping_alone = shopify_rate.tax_shipping_alone
        new_rate.tax_shipping_and_handling_together = shopify_rate.tax_shipping_and_handling_together

        next if rate_row_equal?(shopify_rate, new_rate)
        total_changes += 1

        delta_csv << create_row(new_rate)
        revert_csv << create_row(shopify_rate)
      end
    ensure
      revert_csv.close
      delta_csv.close
    end

    puts "#{total_changes} rows changes"
  end

  desc "updates the usa_tax_rate db from onesource db"
  task calculate_zip: [:environment] do
    rate_db = '/Users/davidrose/Downloads/AS_zip4/AS_zip4.txt'

    zip4 = []
    zip5 = nil
    current_zip = nil
    output_file = CSV.open('zip5_rates.csv', 'w')
    check_file = CSV.open('zip5_check.csv', 'w')
    header_written = false

    CSV.foreach(rate_db, headers: true, col_sep: "\t") do |row|
      unless header_written
        output_file << row.headers
        check_file << row.headers
        header_written = true
      end
      if row['ZIP_CODE'] != current_zip
        new_zip = process_zips(zip4, zip5, check_file) unless current_zip.nil?
        write_onesource_zip(output_file, new_zip)
        zip4 = []
        zip5 = nil
        current_zip = row['ZIP_CODE']
      end

      if row['RECORD_TYPE'] == 'Z'
        zip5 = row
        next
      end
      zip4 << row
    end

    output_file.close
    check_file.close
  end

  def write_onesource_zip(output_file, zip5)
    return if zip5.nil?
    output_file << zip5
  end

  def process_zips(extended_zips, zip5, f)
    return zip5 if extended_zips.empty?

    rates = {
      state: [],
      county: [],
      city: [],
      other1: [],
      other2: [],
      other3: [],
      other4: [],
    }

    zips_by_county = extended_zips.select do |zip|
      zip['COUNTY_NAME'] == zip5['COUNTY_NAME']
    end

    zips_by_city = zips_by_county.select do |zip|
      zip['CITY_NAME'] == zip5['CITY_NAME']
    end

    zips = if !zips_by_city.empty?
             zips_by_city
          elsif !zips_by_county.empty?
            zips_by_county
          else
            extended_zips
          end

    zips.each do |zip|
      rates[:state] << zip['STATE_SALES_TAX']
      rates[:county] << zip['COUNTY_SALES_TAX']
      rates[:city] << zip['CITY_SALES_TAX']
      rates[:other1] << zip['OTHER1_SALES_TAX']
      rates[:other2] << zip['OTHER2_SALES_TAX']
      rates[:other3] << zip['OTHER3_SALES_TAX']
      rates[:other4] << zip['OTHER4_SALES_TAX']
    end


    changed = false
    if zip5['STATE_SALES_TAX'] != mode(rates[:state]) ||
        zip5['COUNTY_SALES_TAX'] != mode(rates[:county]) ||
        zip5['CITY_SALES_TAX'] !=  mode(rates[:city]) ||
        zip5['OTHER1_SALES_TAX'] !=  mode(rates[:other1]) ||
        zip5['OTHER2_SALES_TAX'] !=  mode(rates[:other2]) ||
        zip5['OTHER3_SALES_TAX'] !=  mode(rates[:other3]) ||
        zip5['OTHER4_SALES_TAX'] != mode(rates[:other4])
      changed = true
      f << zip5
    end

    new_zip = zip5.dup
    new_zip['STATE_SALES_TAX'] = mode(rates[:state])
    new_zip['COUNTY_SALES_TAX'] = mode(rates[:county])
    new_zip['CITY_SALES_TAX'] = mode(rates[:city])
    new_zip['OTHER1_SALES_TAX'] = mode(rates[:other1])
    new_zip['OTHER2_SALES_TAX'] = mode(rates[:other2])
    new_zip['OTHER3_SALES_TAX'] = mode(rates[:other3])
    new_zip['OTHER4_SALES_TAX'] = mode(rates[:other4])

    if changed
      f << new_zip
    end

    new_zip
  end

  def unincoporated?(zip)
    zip['CITY_NAME'] =~ /UNINCORPORATED/i
  end

  def mode(arr)
    freq = frequency(arr)
    arr.max_by { |v| freq[v] }
  end

  def frequency(arr)
    arr.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  end
end
