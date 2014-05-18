require 'yaml'

module SidekiqTenantMonitor

  class Configatron
    
    class << self
      
      def load!(file)
        @raw_config = YAML.load_file(file) 
      end

      def raw_config
        @raw_config
      end

      def method_missing(method, *args, &block)
        return @raw_config[method.to_s] if @raw_config[method.to_s]
        super
      end

      def respond_to?(method_sym, include_private = false)
        return true if @raw_config[method_sym.to_s]
        super
      end

    end

  end
end