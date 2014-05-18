module SidekiqTenantMonitor

  module Sinatra
    module MultipleView

      # Enable multiple view finder inside sinatra
      def find_template(views, name, engine, &block)
        Array(views).each {|v|super(v, name, engine, &block) }
      end

      # render with multiple views
      def mrender(name, options={ layout: false })
        render_options = { views: settings.multi_tenant_views }.merge(options)
        erb name, render_options
      end
      
    end
  end
end