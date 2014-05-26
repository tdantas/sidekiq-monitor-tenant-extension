require 'test_helper'
require 'rack/test'

class TestWebTenants < Sidekiq::Test

  describe 'Sidekiq Web Pages' do 
    include Rack::Test::Methods
    def app; Sidekiq::Web; end

    before do 
      ::SidekiqTenantMonitor::LocalPersistence.flush_db!
      ::SidekiqTenantMonitor::Authenticator.register('tdantas', 'secret', 'salt')
      refute SidekiqTenantMonitor::ConnectionManager.tenants.empty?
    end

    def get_page(name)
      connection_tenant_id = SidekiqTenantMonitor::ConnectionManager.tenants.first.id
      get name, { },  'rack.session' => { current_user: 'tdantas', connection_tenant_id: connection_tenant_id }
    end

    ['/busy', '/queues', '/retries', '/scheduled', '/morgue' ].each do |page|

      it "gets properly the url #{page}" do
        get_page(page) 
        assert_equal 200, last_response.status
        assert_equal "http://example.org#{page}" , last_request.url
      end

    end
 
  end
end