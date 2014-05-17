require 'redis'
require 'openssl'
require 'securerandom'

module SidekiqMonitor

  class Authenticator

    # TODO: Instead of compare like that, implement constant time comparison to avoid time attacks
    def self.authenticate(username, password)
      user = User.find(username);
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

    class User

      def self.find(id)
        hash = Redis.current.hgetall("user:#{id}")
        return new(hash) unless hash.empty?
        return nil
      end

      def self.create(username, password, salt=SecureRandom.hex(10))
        id = [ Time.now.to_i, SecureRandom.hex(10)].join('')
        Redis.current.hmset("user:#{username}", 'username', username, 'password', password, 'salt' ,salt, 'id', id );
        new({ "username" => username, "password" =>  password, "salt" => salt, "id" => id})
      end

      attr_reader :name, :salt, :id, :password
      def initialize(hash)
        @id       = hash["id"]
        @name     = hash["username"]
        @salt     = hash["salt"]
        @password = hash["password"]
      end
    end

  end
end