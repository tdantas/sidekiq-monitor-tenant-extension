require 'test_helper'

class TestWebTenants < Sidekiq::Test

  describe 'Authenticator Service' do 

    before do 
      ::SidekiqTenantMonitor::LocalPersistence.flush_db!
      ::SidekiqTenantMonitor::Authenticator.register('tdantas', 'secret', 'salt')
    end

    it 'authenticates a registered user' do
      user = ::SidekiqTenantMonitor::Authenticator.authenticate('tdantas', 'secret')
      assert_equal 'tdantas', user.name
    end

    it 'does not save password as plain text' do 
      user = ::SidekiqTenantMonitor::Authenticator.authenticate('tdantas', 'secret')
      assert ! 'secret'.eql?(user.password)
      assert user.password.length > 0 
    end

    describe 'User authenticator' do

      it 'creates a new user' do 
        user_params = { 'id' => 100, 'username' => 'tdantas', 'salt' => 'salt', 'password' => 'secret'}
        ::SidekiqTenantMonitor::User.create(user_params)
        result = ::SidekiqTenantMonitor::User.find('tdantas')
     
        assert_equal 'tdantas', result.name
        assert_equal 'secret',  result.password
        assert_equal 'salt',    result.salt
        assert_equal '100',      result.id

      end

    end

  end
end