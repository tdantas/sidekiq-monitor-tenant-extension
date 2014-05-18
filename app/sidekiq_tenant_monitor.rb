require 'lib/configatron'
require 'lib/authenticator'
require 'lib/connection_manager'

module SidekiqTenantMonitor

  def self.config
    SidekiqTenantMonitor::Configatron
  end

  def self.boot!
    configatron_setup!
    connection_manager_setup!
    local_persistance_setup!
  end

  private

  def self.connection_manager_setup!
    SidekiqTenantMonitor::ConnectionManager.configure!
  end

  def self.local_persistance_setup!
    SidekiqTenantMonitor::LocalPersistence.setup!
  end
  
  def self.configatron_setup!
    tenants_config = File.expand_path(File.join(File.dirname(__FILE__), 'config/config.yml' ))
    SidekiqTenantMonitor::Configatron.load!(tenants_config)
  end


end

