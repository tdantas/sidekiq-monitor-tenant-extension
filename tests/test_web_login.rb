require 'test_helper'
require 'rack/test'

class TestWebTenants < Sidekiq::Test

  describe 'Authentication endpoint' do 
    include Rack::Test::Methods
    def app; Sidekiq::Web; end

    before do 
      ::SidekiqTenantMonitor::LocalPersistence.flush_db!
      ::SidekiqTenantMonitor::Authenticator.register('tdantas', 'secret', 'salt')
      refute SidekiqTenantMonitor::ConnectionManager.tenants.empty?
    end

    it 'without session redirect to /login' do 
      get '/'
      assert last_response.redirect?
      follow_redirect!
      assert_equal 'http://example.org/login' , last_request.url
    end

    it '/logout clear session and redirects to /login' do 
      get '/logout', { }, 'rack.session' => { current_user: 'tdantas' }
      assert last_response.redirect?
      follow_redirect!
      assert_equal 'http://example.org/login', last_request.url
    end
   
  end
end