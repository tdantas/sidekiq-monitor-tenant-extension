$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

env = ENV['RACK_ENV'] || 'development'
Bundler.require :default, env.to_sym

# Loading sidekiq web monitor
require 'sidekiq/web'

require 'web/app'

tenants_config = File.expand_path(File.join(File.dirname(__FILE__), 'config/config.yml' ))
SidekiqMonitor::ConnectionManager.configure!(tenants_config)

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Redis.current.client.reconnect       
    end
  end
end