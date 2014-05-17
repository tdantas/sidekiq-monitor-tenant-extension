require_relative 'app/boot'

namespace :user do 

  desc 'Register new users'
  task :register do
    STDOUT.print "username: "; username = STDIN.gets.chomp
    STDOUT.print 'password: '; password = STDIN.gets.chomp
    new_user = SidekiqMonitor::Authenticator.register(username, password)
    STDOUT.puts "New user created: #{ new_user.name }"
  end

end

task :default => ['user:register']
