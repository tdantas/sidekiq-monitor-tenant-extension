require 'web/authenticator'
require 'web/connection_manager'
require 'helpers/namespace'
require 'helpers/multiple_views'

module Sidekiq

  class Web < Sinatra::Base

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

    helpers SidekiqMonitor::Sinatra::MultipleView
    helpers SidekiqMonitor::TenantNamespaces                     

    # before filters to redirect to login when not authenticated
    before /^(?!\/login)/ do 
      redirect '/login' unless session[:current_user]
    end

    before /^(?!\/(login|tenants))/ do
      redirect '/tenants' unless SidekiqMonitor::ConnectionManager.switch_to session[:connection_tenant_id]
    end

    # load tenants
    before '/tenants' do 
      @tenants = SidekiqMonitor::ConnectionManager.tenants
    end

    get '/login' do
      mrender :login
    end

    post '/login' do
      user = SidekiqMonitor::Authenticator.authenticate(params[:username], params[:password])

      if user
        session[:current_user] = user.id
        redirect '/tenants'
      else
        @error_message = 'Credentials not found'
        mrender :login
      end
    end

    get '/logout' do 
      session.clear
      redirect '/login'
    end

    get '/tenants' do
      mrender :tenants, layout: :tenant_layout
    end

    post '/tenants' do
      if !!SidekiqMonitor::ConnectionManager.fetch(params[:tenant_id])
        session[:connection_tenant_id] = params[:tenant_id]
        redirect "#{root_path}"
      else
        @error_message = 'Please choose a valid tenant'
        mrender :tenants, layout: :tenant_layout
      end
    end

  end
end