module Sinatra

  module MultipleView

    def find_template(views, name, engine, &block)
      Array(views).each {|v|super(v, name, engine, &block) }
    end
    
    def mrender(name, layout=false)
      erb name, views: settings.multi_tenant_views, layout: layout
    end

  end

end