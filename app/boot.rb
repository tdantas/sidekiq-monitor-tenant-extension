$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

env = ENV['RACK_ENV'] || 'development'
Bundler.require :default, env.to_sym

require 'sidekiq_tenant_monitor'
SidekiqTenantMonitor.boot!

# Loading sidekiq web monitor
require 'sidekiq/web'
require 'web/app'

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      SidekiqTenantMonitor::LocalPersistence.reconnect!
      SidekiqTenantMonitor::ConnectionManager.reconfigure!    
    end
  end
end