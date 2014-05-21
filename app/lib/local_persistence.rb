require 'redis'

module SidekiqTenantMonitor


  class LocalPersistence

    def self.key(key)
      @key = key
    end

    def self.index_by(name)
      @index = name
    end

    def self.interpolate_key(id)
      @key.call(id)
    end

    def self.reconnect!
      redis.client.reconnect
    end    

    def self.flush_db!
      redis.flushdb
    end
    
    def self.setup!(config=SidekiqTenantMonitor.config)
      @redis = Redis.new(url: config.local['url'])
    end

    def self.redis
      setup! unless @redis
      @redis || LocalPersistence.redis
    end

    def self.find(id)
      hash = redis.hgetall( interpolate_key(id) )
      return new(hash) unless hash.empty?
      return nil    
    end

    def self.create(hash)
      id = hash['id'] || [ Time.now.to_i, SecureRandom.hex(10)].join('')
      with_id_hash = hash.merge({'id' => id})

      hash_array = with_id_hash.to_a.reduce([]) { |acc, curr| acc.concat(curr) }
      idx = with_id_hash[@index]
      
      redis.hmset(interpolate_key(idx), *hash_array);
      new(with_id_hash)
    end

  end
end