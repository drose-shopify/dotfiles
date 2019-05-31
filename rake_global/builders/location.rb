# typed: true
module Builder
  module Location
    class << self
      def create(shop)
        state, zip = Shopify::Faker::Address.state_and_zip_code_for_country('US')

        options = {
          name: "#{Shopify::Faker::Address.city_prefix} #{Shopify::Faker::Address.country}",
          address1: Shopify::Faker::Address.street_address,
          address2: Shopify::Faker::Address.secondary_address,
          zip: zip,
          city: Shopify::Faker::Address.city,
          province: state,
          country: 'US',
          phone: Shopify::Faker::Address.phone_number,
        }

        @location = ShopIdentity::LocationService.new(shop.trusted_id).create_location(options)
        raise ActiveRecord::RecordInvalid, @location unless @location.valid?
      end
    end
  end
end
