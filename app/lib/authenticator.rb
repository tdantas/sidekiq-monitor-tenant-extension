require 'redis'
require 'openssl'
require 'securerandom'

require 'lib/local_persistence'

module SidekiqTenantMonitor

  class User < LocalPersistence

    key proc { |id| "user:#{id}" }

    attr_reader :name, :salt, :id, :password
    def initialize(hash)
      @id       = hash["id"]
      @name     = hash["username"]
      @salt     = hash["salt"]
      @password = hash["password"]
    end
  
  end

  class Authenticator

    # TODO: Instead of compare like that, implement constant time comparison to avoid time attacks
    def self.authenticate(username, password)
      user = User.find(username)
      return false unless user
      user if hashify(password, user.salt) == user.password
    end

    def self.register(username, password)
      salt = SecureRandom.hex(10)
      User.create(username, hashify(password, salt), salt)
    end

    def self.hashify(value, salt, digest='SHA256')
      OpenSSL::HMAC.hexdigest(digest, salt, value)
    end

  end
end