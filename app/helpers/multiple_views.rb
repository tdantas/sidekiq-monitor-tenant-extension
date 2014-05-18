module SidekiqMonitor

  module Sinatra
    module MultipleView

      def find_template(views, name, engine, &block)
        Array(views).each {|v|super(v, name, engine, &block) }
      end

      def mrender(name, options={ layout: false })
        render_options = { views: settings.multi_tenant_views }.merge(options)
        erb name, render_options
      end
      
    end
  end
end