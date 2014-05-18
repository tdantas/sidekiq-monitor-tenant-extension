require 'securerandom'

module SidekiqMonitor

  class ConnectionManager

    def self.configure!(config_file)
      config = YAML.load_file(config_file)
      config['sidekiqs'].each do |tenant|
        register(tenant) 
      end
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

    def self.fetch(id)
      tenants.each do |tenant|
        return tenant if tenant.id == id 
      end
      return nil
    end

  end

  class Tenant

    attr_reader :id, :name, :pool
    
    def initialize(name, redis)
      @id   = SecureRandom.hex(5)
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