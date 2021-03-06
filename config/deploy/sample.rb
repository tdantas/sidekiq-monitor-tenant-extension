puts "\e[0;35m =======================================================\e[0m\n"
puts "\e[0;35m              DEPLOYING TO <ENV>\e[0m\n"
puts "\e[0;35m =======================================================\e[0m\n"

set :rails_env, "<ENV>"
set :domain, '<HOST>'
set :runner, "<USER>"

server domain, :app, :web

role :db, domain, :primary => true

ssh_options[:forward_agent] = true
ssh_options[:user] = runner

set :branch, "<ENV>"
set :deploy_to, "/var/www/#{application}"
