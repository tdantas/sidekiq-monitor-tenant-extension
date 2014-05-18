module SidekiqTenantMonitor

  module TenantNamespaces
    
    # Override to avoid memoizing at @@ns variable
    def namespace
      Sidekiq.redis {|conn| conn.respond_to?(:namespace) ? conn.namespace : nil }
    end
  end

end