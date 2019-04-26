# frozen_string_literal: true
require_relative 'shopify_tasks'

module Scenarios
  extend self
  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  def exemptions
    @exemptions ||= TaxExemption::TYPES.map do |exempt_type|
      {exempt_type: Taxes::TaxExemptionSchema.new(exemption_type: exempt_type)}
    end.reduce({}, :merge!)
  end

  def possible_names
    @possible_names ||= begin
      first_names    = Shopify::Faker::Base.fetch_all('name.first_name').sample(10)
      last_names     = Shopify::Faker::Base.fetch_all('name.last_name').sample(10)
      first_names.product(last_names)
    end
  end

  def random_name_email(shop)
    used_emails = shop.customers.select(:email).pluck(:email)
    available_names = possible_names.reject { |n| used_emails.include?("#{n.join}@example.com") }
    name_to_use = available_names.sample
    [name_to_use.first, name_to_use.last, "#{name_to_use.join}@example.com"]
  end

  namespace :scenario do
    namespace :canada do
      desc "Adds various customers with various exemptions"
      task exemptions: [:environment] do
        country = 'CA'
        
        exemptions = [
          [exemptions['CA_STATUS_CARD_EXEMPTION']],
          [
            exemptions['CA_BC_RESELLER_EXEMPTION']
          ],[
            exemptions['CA_MB_RESELLER_EXEMPTION']
          ]
        ]


      end
    end
  end
end