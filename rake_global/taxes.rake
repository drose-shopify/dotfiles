# frozen_string_literal: true
require_relative 'shopify_tasks'

module TaxesTasks
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

  namespace :taxes do
    desc "Enables all tax betas" 
    task enable_edge: [:environment] do
      shop_web = ApiClient.find_by(handle: 'shopify-web')

      api_betas = [
        {
          feature: 'tax_exemptions_for_customer',
          state: :enable,
        }, {
          feature: 'taxes_graphql_api',
          state: :enable,
        }, {
          feature: 'tax_overrides_api',
          state: :enable,
        },
      ]

      shop_betas = [
        {
          feature: 'new-admin-taxes-routes',
          state: :enable,
        }, {
          feature: 'tax_enable_migration_flow',
          state: :disable,
        }, {
          feature: 'tax_migration_exclusion',
          state: :disable,
        }, {
          feature: 'use_active_tax_engine',
          state: :enable,
        },
      ]
      
      configure_betas(obj: shop_web, features: api_betas)
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

    desc "Setup Avalara Sandbox"
    task enable_avalara: [:environment] do
      avalara_plan_feature = { avalara: {avalara_avatax: true} }
      plan = ENV['PLAN'] || 'shopify_plus'
      shop = shop_from_env

      puts "Changing shop plan to #{plan}"
      shop.change_subscription(PlanSpec.new(plan, avalara_plan_feature))
    end

    desc "Verifies a rate file with the usa_tax_rate table"
    task verify_rates: [:environment] do
      file_path = ENV['RATE_FILE']
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
end