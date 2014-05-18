require 'redis'

module SidekiqTenantMonitor


  class LocalPersistence

    def self.key(key)
      @key = key
    end

    def self.interpolate_key(id)
      @key.call(id)
    end    
    
    def self.setup!(config=SidekiqTenantMonitor.config)
      @redis = Redis.new(url: config.local['url'])
      @redis.client.connect
    end

    def self.redis
      @redis || LocalPersistence.redis
    end

    def self.find(id)
      hash = redis.hgetall( interpolate_key(id) )
      return new(hash) unless hash.empty?
      return nil    
    end

    def self.create(username, password, salt=SecureRandom.hex(10))
      id = [ Time.now.to_i, SecureRandom.hex(10)].join('')
      redis.hmset(interpolate_key(username), 'username', username, 'password', password, 'salt' ,salt, 'id', id );
      new({ "username" => username, "password" =>  password, "salt" => salt, "id" => id})
    end

  end
end