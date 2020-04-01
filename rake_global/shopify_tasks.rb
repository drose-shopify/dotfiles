# frozen_string_literal: true
shopify_root = File.expand_path('~/src/github.com/Shopify/shopify')
Dir.chdir(shopify_root)

require File.join(shopify_root, 'config', 'application')
Rails.application.load_tasks

require 'development_support'
require 'development_support/shop_builder'
require 'development_support/exchange_rate_setup'
require 'development_support/gateway_setup'
require 'development_support/resource_feedbacks_helper'
require 'rake_task_with_pod_selection'

module ShopifyHelper
  def pod_id_from_env
    if ENV['SUBJECT'] # for Verdict compatibility
      ENV['SHOP_ID'] = Verdict::Rake.subject_identifier
    end
    super
  end

  def shop_from_env(order = :last)
    @shop_from_env ||= if ENV.key?("SHOP_ID")
      Shop.find(ENV["SHOP_ID"])
    elsif Shop.any?
      order = :last unless [:first, :last].include?(order)
      Shop.public_send(order)
    else
      raise "No shops found. Run rake dev:shop:create to create one."
    end
  end

  def reset_shop_from_env
    @shop_from_env = nil
  end

  def api_clients
    @api_clients ||= YAML.load_file(File.join(Rails.root, 'lib', 'development_support', 'api_clients.yml'))
  end

  def api_clients_from_env(default: 'facebook')
    api_client_handles = ENV.fetch('API_CLIENT_HANDLES', default)
    handles = api_client_handles.split(',').map(&:strip)
    ApiClient.where(handle: handles)
  end

  def create_and_authorize_api_client(api_client_opts = {})
    api_client = DevelopmentSupport::ShopBuilder::ApiClient.create(api_client_opts)
    puts "- API Client '#{api_client.title}'. api_key: #{api_client.api_key} shared_secret: #{api_client.shared_secret}"
    Apps::Installations::EnsureInstalled.perform(
      app_id: api_client.id,
      shop_id: shop.id,
      access_scope: Access::Scope.for_client(api_client, shop).map(&:to_s)
    )
    puts "- Installed '#{api_client.title}' to shop ##{shop.id}."

    api_client
  end
end
