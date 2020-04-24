# frozen_string_literal: true
require_relative 'shopify_tasks'

EU_CUSTOMERS = [{
  first_name: 'EU',
  last_name: 'Germany',
  address: {
    address1: 'Kastanienallee 90',
    city: 'Bargstedt',
    province: 'SH',
    zip: '24793',
    country: 'DE',
  },
}, {
  first_name: 'EU',
  last_name: 'Spain',
  address: {
    address1: 'Canónigo Valiño 39',
    city: 'Buñol',
    province: 'Valencia',
    zip: '46360',
    country: 'ES',
  },
}, {
  first_name: 'EU',
  last_name: 'Azores',
  address: {
    address1: 'R. da Juventude',
    address2: '',
    city: 'Ponta Delgada',
    province: 'PT-20',
    zip: '9500-211',
    country: 'PT',
  },
}, {
  first_name: 'EU',
  last_name: 'Portugal',
  address: {
    address1: 'Campo de Santa Clara',
    city: 'Santa Clara',
    province: 'PT-11',
    zip: '1100-472',
    country: 'PT',
  },
}, {
    first_name: 'Canada',
    last_name: 'LloydMinster',
    address: {
      address1: '3902 44 St',
      city: 'Lloydminster',
      province: 'SK',
      zip: 'S9V0ZB',
      country: 'CA',
    }
}, {
    first_name: 'EU',
    last_name: 'Ireland',
    address: {
      address1: '4PVP+6V',
      city: 'Dingle',
      province: 'KY',
      zip: '',
      country: 'IE',
    }
}]

module TaxesDev
  extend self
  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  def location_service
    @location_service ||= ShopIdentity::LocationService.new(shop_from_env.trusted_id)
  end

  namespace :taxes_dev do
    desc "Setup shipping location for CA"
    task setup_shipping_ca: [:environment] do
      shop = shop_from_env

      address = {
        name: "Canada Origin Address",
        address1: '85 Willis Way',
        address2: nil,
        zip: 'N2Y3T5',
        city: 'Waterloo',
        province: 'ON',
        country: 'CA',
        phone: Shopify::Faker::Address.phone_number,
      }

      location = shop.locations.find_by(name: address[:name])

      if location.nil?
        puts "Creating canada shipping address"
        location = location_service.create_location(address)
        raise ActiveRecord::RecordInvalid, location unless location.valid?
      end

      puts "Setting default shipping address"
      location_service.set_location_as_shipping_address(location.id)
    end
    desc "Setup shipping location for EU"
    task setup_shipping_eu: [:environment] do
      shop = shop_from_env

      address = {
        name: "EU Origin Address",
        address1: '7WCw+CC',
        address2: nil,
        zip: '7WCw+CC',
        city: 'Galway',
        province: 'G',
        country: 'IE',
        phone: Shopify::Faker::Address.phone_number,
      }

      location = shop.locations.find_by(name: address[:name])

      if location.nil?
        puts "Creating EU shipping address"
        location = location_service.create_location(address)
        raise ActiveRecord::RecordInvalid, location unless location.valid?
      end

      puts "Setting default shipping address"
      location_service.set_location_as_shipping_address(location.id)
    end

    desc "Create Development Customers"
    task create_customers: [:environment] do
      shop = shop_from_env

      EU_CUSTOMERS.each do |customer|
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

    desc "Update shop for dev"
    task update_shop_ca: [:environment] do
      shop = shop_from_env
      condensed_date = Date.today.strftime('%Y%m%d')

      shop.address1 = '85 Willis Way'
      shop.city = 'Waterloo'
      shop.province = 'ON'
      shop.country = 'CA'
      shop.zip = 'N2Y3T5'
      shop.order_number_format = "drose-#{condensed_date}-\#{{number}}"

      shop.save!(validate: false)
    end
    desc "Update shop for dev"
    task update_shop_eu: [:environment] do
      shop = shop_from_env
      condensed_date = Date.today.strftime('%Y%m%d')

      shop.address1 = '7WCw+CC'
      shop.city = 'Galway'
      shop.province = 'G'
      shop.country = 'IE'
      shop.zip = ''
      shop.order_number_format = "drose-#{condensed_date}-\#{{number}}"

      shop.save!(validate: false)
    end

    desc "Setup data for EU"
    unpodded_task setup_eu: [:environment] do
      puts "Updating shop information"
      Rake::Task['taxes_dev:update_shop_eu'].invoke

      puts "Setup shipping"
      Rake::Task['taxes_dev:setup_shipping_eu'].invoke

      puts "Creating Customers"
      Rake::Task['taxes_dev:create_customers'].invoke
    end

    desc "Setup data for CA"
    unpodded_task setup_ca: [:environment] do
      puts "Updating shop information"
      Rake::Task['taxes_dev:update_shop_ca'].invoke

      puts "Setup shipping"
      Rake::Task['taxes_dev:setup_shipping_ca'].invoke

      puts "Creating Customers"
      Rake::Task['taxes_dev:create_customers'].invoke
    end
  end
end
