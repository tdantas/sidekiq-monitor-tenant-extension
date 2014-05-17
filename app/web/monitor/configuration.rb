require 'yaml'

module SidekiqMonitor
  class Configuration
    
    def self.load(file)
      new YAML.load_file(file)
    end

    def initialize(hash = {})
      @configs = hash
    end

    def method_missing(name, *args, &block)
      value = (@configs[name.to_s] || @configs[name])
      return value if value
      super
    end

    def respond_to(name)
      !!(@configs[name] || @configs[name.to_sym])
    end

  end
end