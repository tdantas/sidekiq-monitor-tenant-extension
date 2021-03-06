require 'digest'

module SidekiqTenantMonitor

  class ConnectionManager

    def self.configure!(config = SidekiqTenantMonitor.config)
      config.sidekiqs.each do |tenant|
        register(tenant) 
      end
    end

    def self.reconfigure!(config = SidekiqTenantMonitor.config)
      @tenants = []
      configure!(config)
    end

    def self.tenants
      @tenants || []
    end

    def self.register(tenant)
      @tenants = [] unless @tenants
      tenant = Tenant.new(tenant["name"], tenant["redis"])
      tenants.push(tenant)
      tenant.start!
    end

    def self.switch_to(id)
      return nil unless tenant = fetch(id)
      Sidekiq.redis = tenant.pool
    end

    def self.fetchByName(name, default=nil)
      iterate { |t| return t if t.name == name }
      return default
    end

    def self.fetch(id)
      iterate { |t| return t if t.id == id } 
      return nil
    end

    private
    def self.iterate(&block)
      tenants.each &block
    end

  end

  class Tenant

    attr_reader :id, :name, :pool
    
    def initialize(name, redis)
      @id   = Digest::MD5.hexdigest(name)
      @name = name
      @redis = redis
    end

    def namespace
      @redis["namespace"]
    end

    def url
      @redis["url"]
    end

    def start!
      @pool = ::Sidekiq::RedisConnection.create({ url: url, namespace: namespace })
    end 

  end

end