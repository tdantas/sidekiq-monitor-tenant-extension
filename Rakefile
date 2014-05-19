require_relative 'app/boot'

namespace :user do 

  desc 'Register new users'
  task :register do
    STDOUT.print "Username: "; username = STDIN.gets.chomp
    STDOUT.print 'Password: '; password = STDIN.gets.chomp
    new_user = SidekiqTenantMonitor::Authenticator.register(username, password)
    STDOUT.puts "New user created: #{ new_user.name }"
  end

end

task :default => ['user:register']
