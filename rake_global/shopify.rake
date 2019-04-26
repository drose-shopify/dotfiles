# frozen_string_literal: true
require_relative 'shopify_tasks'

module ShopifyTasks
  extend self
  extend Rake::DSL
  extend RakeTaskWithPodSelection
  extend ShopifyHelper

  namespace :shopify do
    
  end
end