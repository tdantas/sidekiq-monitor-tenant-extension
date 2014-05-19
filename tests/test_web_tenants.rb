require 'test_helper'
require 'rack/test'

class TestWebTenants < Sidekiq::Test

  describe 'tenants endpoint' do 
    include Rack::Test::Methods
    def app; Sidekiq::Web; end

    describe "GET /tenants without session" do

     it 'without session must redirect to /login' do
        get '/tenants'
        assert last_response.redirect?
        follow_redirect!
        assert_equal 'http://example.org/login' , last_request.url
      end
      
    end

    describe "GET /tenants with session" do 
      
      before do 
        ::SidekiqTenantMonitor::LocalPersistence.flush_db!
        ::SidekiqTenantMonitor::Authenticator.register('tdantas', 'secret', 'salt')
        refute SidekiqTenantMonitor::ConnectionManager.tenants.empty?
      end

      it 'without connection tenant chosen, redirects to /tenants' do 
        get '/', { },  'rack.session' => { :current_user => 'tdantas' }
        assert last_response.redirect?
        follow_redirect!
        assert_equal 'http://example.org/tenants' , last_request.url
      end


      it '/tenants must contains all tenants configured as option' do
        get '/tenants', {}, 'rack.session' => { :current_user => 'tdantas' }
        SidekiqTenantMonitor::ConnectionManager.tenants.each do |tenant|
          assert_match(/#{tenant.id}/, last_response.body)
        end
      end

      it 'accepts / when already setup the connection' do 
        connection_tenant_id = SidekiqTenantMonitor::ConnectionManager.tenants.first.id
        get '/', { },  'rack.session' => { current_user: 'tdantas', connection_tenant_id: connection_tenant_id }
        assert_equal 200, last_response.status
        assert_equal 'http://example.org/', last_request.url
      end

    end

  end
end