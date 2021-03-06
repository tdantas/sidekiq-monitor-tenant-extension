require 'lib/authenticator'
require 'lib/connection_manager'

require 'helpers/namespace'
require 'helpers/multiple_views'

module Sidekiq

  class Web < Sinatra::Base

    helpers SidekiqTenantMonitor::Sinatra::MultipleView
    helpers SidekiqTenantMonitor::TenantNamespaces                     

    enable :raise_errors
    disable :show_exceptions
    
    DEFAULT_TABS.merge!({ 
      'Tenant' => 'tenants', 
      '<b>Logout</b>' => 'logout'
    })

    use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => SidekiqTenantMonitor.config.secret

    # before filters to redirect to login when not authenticated
    before /^(?!\/login)/ do 
      redirect '/login' unless session[:current_user]
    end

    # on purpose to devops bookmark tenants page
    before /^(?!\/(login|tenants|logout))/ do
      break unless params[:tenant_name]
      tenant = SidekiqTenantMonitor::ConnectionManager.fetchByName(params[:tenant_name])
      session[:connection_tenant_id] = tenant.id if tenant
    end

    before /^(?!\/(login|tenants|logout))/ do
      redirect '/tenants' unless SidekiqTenantMonitor::ConnectionManager.switch_to session[:connection_tenant_id]
    end

    # load tenants
    before '/tenants' do 
      @tenants = SidekiqTenantMonitor::ConnectionManager.tenants
    end

 
    get '/login' do
      mrender :login
    end

    post '/login' do
      user = SidekiqTenantMonitor::Authenticator.authenticate(params[:username], params[:password])

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
      if !!SidekiqTenantMonitor::ConnectionManager.fetch(params[:tenant_id])
        session[:connection_tenant_id] = params[:tenant_id]
        redirect "#{root_path}"
      else
        @error_message = 'Please choose a valid tenant'
        mrender :tenants, layout: :tenant_layout
      end
    end

  end
end