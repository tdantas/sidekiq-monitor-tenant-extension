require 'web/authenticator'

module Sidekiq

  class Web < Sinatra::Base

    include Sinatra::MultipleView

    set :multi_tenant_root, File.expand_path("../../" , __FILE__)
    set :multi_tenant_views, [ "#{multi_tenant_root}/views", views ]

    enable :raise_errors
    disable :show_exceptions
    
    DEFAULT_TABS.merge!({ 
      'Tenant' => 'tenants', 
      '<b>Logout</b>' => 'logout'
    })

    use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'Please, you must change this sescret in production, ok! Do not forget '


    # Override to avoid memoizing
    def namespace
      Sidekiq.redis {|conn| conn.respond_to?(:namespace) ? conn.namespace : nil }
    end                       

    before /^(?!\/login)/ do 
      redirect '/login' unless session[:current_user]
    end

    before /^(?!\/(login|tenants))/ do
      redirect '/tenants' unless SidekiqMonitor::ConnectionManager.switch_to session[:connection_tenant_id]
    end

    get '/login' do
      erb :login, views: settings.multi_tenant_views, layout: false
    end

    post '/login' do
      user = SidekiqMonitor::Authenticator.authenticate(params[:username], params[:password])

      if user
        session[:current_user] = user.id
        redirect '/tenants'
      else
        @error_message = 'Credentials not found'
        erb :login, views: settings.multi_tenant_views, layout: false
      end
    end

    get '/logout' do 
      session.clear
      redirect '/login'
    end

    get '/tenants' do
      @tenants = SidekiqMonitor::ConnectionManager.tenants
      erb :tenants, views: settings.multi_tenant_views, layout: :tenant_layout
    end

    post '/tenants' do
      if !!SidekiqMonitor::ConnectionManager.fetch(params[:tenant_id])
        session[:connection_tenant_id] = params[:tenant_id]
        redirect "#{root_path}"
      else
        @error_message = 'Please choose a valid tenant'
        erb :tenants, views: settings.multi_tenant_views, layout: :tenant_layout
      end
    end

  end
end