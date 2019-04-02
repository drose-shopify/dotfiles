# frozen_string_literal: true
require 'csv'
class TaxUtils
  def self.string_to_bool(data)
    return data if !!data == data
    return true if data.casecmp('y').zero? || data.casecmp('true').zero?
    
    false
  end
  def self.verify_rates(file_path)
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
end