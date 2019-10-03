# frozen_string_literal: true
require_relative 'shopify_tasks'
require 'yaml'
require 'csv'
require 'bigdecimal'
require 'net/ftp'
require 'zip'

module TaxRateUtils
  extend self
  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  desc "Updates the usa_tax_rate db from onesource db"
  task update_tax_rates: [:environment] do
    force_download = !!ENV['FORCE_DOWNLOAD']
    begin
      puts "Looking for new rate file"
      rate_db_zip = download_rate_file(force_download)
      if rate_db_zip.nil?
        puts "No new rate file found"
        break
      end

      puts "Extracting zip"
      rate_db_file = extract_rate_file(rate_db_zip)

      puts "Calculating 5-digit zip taxes"
      zip5_file = create_zip5_csv(rate_db_file)

      delta_file_name = ENV['OUTPUT_FILE'] || "db/avalara/delta_#{Date.today.strftime('%b_%d_%Y').downcase}.csv"

      revert_csv = CSV.open(File.join(File.dirname(delta_file_name), "revert_#{File.basename(delta_file_name)}"), 'w')
      delta_csv = CSV.open(delta_file_name, 'w')

      total_changes = 0
      write_delta_headers(revert_csv)
      write_delta_headers(delta_csv)
      puts "Checking rate file for differences"
      tax_rates(zip5_file) do |zip|
        shopify_rate = ::USATaxRate.find_by(zip_code: zip.zip_code.to_s)
        if shopify_rate.blank?
          next
        end

        new_rate = shopify_rate.dup

        new_rate.state_sales_tax = zip.state_sales_tax
        new_rate.county_sales_tax = zip.county_sales_tax
        new_rate.city_sales_tax = zip.city_sales_tax + zip.other_sales_tax
        new_rate.total_sales_tax = zip.total_sales_tax
        new_rate.tax_shipping_alone = shopify_rate.tax_shipping_alone
        new_rate.tax_shipping_and_handling_together = shopify_rate.tax_shipping_and_handling_together

        next if rate_row_equal?(shopify_rate, new_rate)
        total_changes += 1

        delta_csv << create_row(new_rate)
        revert_csv << create_row(shopify_rate)
      end
      puts "#{total_changes} rows affected"
    ensure
      revert_csv.close unless revert_csv.nil?
      delta_csv.close unless delta_csv.nil?
      File.delete(zip5_file)
      File.delete(rate_db_file)
      File.delete(rate_db_zip)
    end
  end

  def tax_rates(rate_file)
    CSV.foreach(rate_file, headers: true, col_sep: ",") do |row|
      next if row['RECORD_TYPE'] != 'Z'
      state_rate = row['STATE_SALES_TAX'].to_d
      county_rate = row['COUNTY_SALES_TAX'].to_d
      city_rate = row['CITY_SALES_TAX'].to_d
      other_rates = row['MTA_SALES_TAX'].to_d +
        row['SPD_SALES_TAX'].to_d +
        row['OTHER1_SALES_TAX'].to_d +
        row['OTHER2_SALES_TAX'].to_d +
        row['OTHER3_SALES_TAX'].to_d +
        row['OTHER4_SALES_TAX'].to_d
      total_tax_rate = state_rate + county_rate + city_rate + other_rates

      yield(
        OpenStruct.new(
          zip_code: row['ZIP_CODE'],
          state_sales_tax: state_rate,
          county_sales_tax: county_rate,
          city_sales_tax: city_rate,
          other_sales_tax: other_rates,
          total_sales_tax: total_tax_rate
        )
      )
    end
  end

  def rate_row_equal?(old_row, new_row)
    return false unless BigDecimal(old_row.state_sales_tax, 8) == BigDecimal(new_row.state_sales_tax, 8)
    return false unless BigDecimal(old_row.county_sales_tax, 8) == BigDecimal(new_row.county_sales_tax, 8)
    return false unless BigDecimal(old_row.city_sales_tax, 8) == BigDecimal(new_row.city_sales_tax, 8)
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

  def write_delta_headers(csv)
    csv << ['zip_code','state_abbrev','county_name','city_name','state_sales_tax','county_sales_tax','city_sales_tax','total_sales_tax','tax_shipping_alone','tax_shipping_and_handling_together']
  end

  def download_rate_file(force = false)
    rate_db_file = nil
    Net::FTP.open('ftp.taxdatasystems.com') do |ftp|
      ftp.login('shopify1', 'shopify99')
      current_file_date = Date.today
      ftp.nlst.each do |filename|
        file_date = ftp.mtime(filename).to_date
        if file_date >= current_file_date
          rate_db_file = filename
          current_file_date = file_date
        end
      end
      if force && rate_db_file.nil?
        rate_db_file = ftp.nlst.first
      end

      unless rate_db_file.nil?
        puts "Downloading #{rate_db_file}"
        ftp.getbinaryfile(rate_db_file)
      end
    end
    rate_db_file
  end

  def extract_rate_file(zip_file)
    output_file = 'rate_db.txt'
    Zip::File.open(zip_file) do |archive|
      entry = archive.glob("#{File.basename(zip_file, '.*')}.txt").first
      entry.extract(output_file)
    end
    output_file
  end

  def create_zip5_csv(rate_db)
    extended_zips = []
    zip5 = nil
    current_zip = nil
    output_file_name = 'zip5_rates.csv'
    output_file = CSV.open(output_file_name, 'w')
    header_written = false

    CSV.foreach(rate_db, headers: true, col_sep: "\t") do |row|
      unless header_written
        output_file << row.headers
        header_written = true
      end
      if row['ZIP_CODE'] != current_zip
        new_zip = get_zip5(extended_zips, zip5) unless current_zip.nil?
        write_onesource_zip(output_file, new_zip)
        extended_zips = []
        zip5 = nil
        current_zip = row['ZIP_CODE']
      end

      if row['RECORD_TYPE'] == 'Z'
        zip5 = row
        next
      end
      extended_zips << row
    end

    output_file.close
    output_file_name
  end

  def write_onesource_zip(output_file, zip5)
    return if zip5.nil?
    output_file << zip5
  end

  def get_zip5(extended_zips, zip5)
    return zip5 if extended_zips.empty?

    # See: https://github.com/Shopify/taxes/issues/1328
    # In order to get a more accurate zip5 rate we need to break
    # down the zip4s by county then by city according to the zip5 entry
    # We attempt to take the `mode` of each rate for all entries
    # that we have found.
    #
    # If no entries exist for a county/city then only use entries with
    # the same county as the zip5. If no county matches the zip5 then use
    # all available zips to calculate a rate

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


    new_zip = zip5.dup
    new_zip['STATE_SALES_TAX'] = mode(rates[:state])
    new_zip['COUNTY_SALES_TAX'] = mode(rates[:county])
    new_zip['CITY_SALES_TAX'] = mode(rates[:city])
    new_zip['OTHER1_SALES_TAX'] = mode(rates[:other1])
    new_zip['OTHER2_SALES_TAX'] = mode(rates[:other2])
    new_zip['OTHER3_SALES_TAX'] = mode(rates[:other3])
    new_zip['OTHER4_SALES_TAX'] = mode(rates[:other4])

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
