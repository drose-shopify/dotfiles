# frozen_string_literal: true
require_relative 'shopify_tasks'

AVALARA_CUSTOMERS = [{
  first_name: 'Avalara',
  last_name: 'NewYork',
  address: {
    address1: '111 8th Ave',
    city: 'New York',
    province: 'NY',
    zip: '10011',
    country: 'US',
  },
}, {
  first_name: 'Avalara',
  last_name: 'California',
  address: {
    address1: '1024 Summit Dr.',
    city: 'Beverly Hills',
    province: 'CA',
    zip: '90210',
    country: 'US',
  },
}, {
  first_name: 'Avalara',
  last_name: 'Texas',
  address: {
    address1: '12357-A Riata Trace Pkwy Bldg 5',
    address2: 'Suite 200',
    city: 'Austin',
    province: 'TX',
    zip: '78727',
    country: 'US',
  },
}, {
  first_name: 'Avalara',
  last_name: 'Canada',
  address: {
    address1: '3601 W 10th Ave',
    city: 'Vancouver',
    province: 'BC',
    zip: 'V6R2G2',
    country: 'CA',
  },
}, {
    first_name: 'Texas',
    last_name: 'MultiSPDRates',
    address: {
      address1: '219 Shady Lane Drive',
      city: 'Fort Worth',
      province: 'TX',
      zip: '76112',
      country: 'US',
    }
}]

module AvalaraTasks
  extend self
  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  def location_service
    @location_service ||= ShopIdentity::LocationService.new(shop_from_env.trusted_id)
  end

  namespace :avalara do
    desc "Enable shop to use Avalara"
    task enable: [:environment] do
      avalara_plan_feature = { avalara: {avalara_avatax: true} }
      plan = ENV['PLAN'] || 'shopify_plus'
      shop = shop_from_env

      puts "Changing shop plan to #{plan}"
      shop.change_subscription(PlanSpec.new(plan, avalara_plan_feature))
    end

    desc "Setup shipping location for Avalara"
    task setup_shipping: [:environment] do
      shop = shop_from_env

      address = {
        name: "Avalara Origin Address",
        address1: '2-230 Hoyt St.',
        address2: nil,
        zip: '11217',
        city: 'Brooklyn',
        province: 'NY',
        country: 'US',
        phone: Shopify::Faker::Address.phone_number,
      }

      location = shop.locations.find_by(name: address[:name])

      if location.nil?
        puts "Creating avalara shipping address"
        location = location_service.create_location(address)
        raise ActiveRecord::RecordInvalid, location unless location.valid?
      end

      puts "Setting default shipping address"
      location_service.set_location_as_shipping_address(location.id)
    end

    desc "Create Avalara customers"
    task create_customers: [:environment] do
      shop = shop_from_env

      AVALARA_CUSTOMERS.each do |customer|
        customer_email = "#{customer[:first_name]}.#{customer[:last_name]}@example.com"
        next if shop.customers.where(email: customer_email).exists?

        puts "Creating customer [#{customer[:first_name]} #{customer[:last_name]}]"

        customer_entity = shop.customers.build(
            first_name: customer[:first_name],
            last_name: customer[:last_name],
            email: customer_email,
            password: "password",
            password_confirmation: "password",
            origin: %w(storefront pos credit_card).sample,
            tags: %w(avalara),
          )

        customer_entity.addresses << ::CustomerAddress.new(customer[:address])

        customer_entity.save!
        customer_entity.reload
      end
    end

    desc "Update shop for Avalara"
    task update_shop: [:environment] do
      shop = shop_from_env
      condensed_date = Date.today.strftime('%Y%m%d')

      shop.address1 = '85 Willis Way'
      shop.city = 'Waterloo'
      shop.province = 'Ontario'
      shop.country = 'CA'
      shop.zip = 'N2H3V1'
      shop.order_number_format = "drose-#{condensed_date}-\#{{number}}"

      shop.save!(validate: false)
    end

    desc "Setup data and enable Avalara"
    unpodded_task setup: [:environment] do
      puts "Enabling Avalara"
      Rake::Task['avalara:enable'].invoke

      puts "Updating shop information"
      Rake::Task['avalara:update_shop'].invoke

      puts "Setup shipping"
      Rake::Task['avalara:setup_shipping'].invoke

      puts "Creating Avalara Customers"
      Rake::Task['avalara:create_customers'].invoke
    end
  end
end
