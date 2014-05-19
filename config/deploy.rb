require "bundler/capistrano"
require 'capistrano/ext/multistage'

set :stages, %w(production staging)

set :deploy_location do
  deploy_to = Capistrano::CLI.ui.ask 'Deploy to (p)roduction or (s)taging [s]: '
  case deploy_to.split.first
    when 'p' then :production
    when 's' then :staging
    else :staging
  end
end

set :default_stage, deploy_location
set :keep_releases, 4
set :normalize_asset_timestamps, false

set :application, "sidekiq-monitor"
set :deploy_via, :remote_cache
set :repository, "git@github.com:tdantas/sidekiq-monitor-tenant-extension.git"

default_run_options[:pty] = true
set :use_sudo, false
set :port, 22

namespace :deploy do
    # Restart passenger on deploy
    desc "Restarting mod_rails with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
        run "touch #{release_path}/tmp/restart.txt"
    end

    [:start, :stop].each do |t|
        desc "#{t} task is a no-op with mod_rails"
        task t, :roles => :app do ; end
    end

    desc "copies configuration files"
    task :copy_configuration_files, :roles => :app do
        run "mkdir -p #{shared_path}/config"
        run_locally "scp app/config/config.yml #{runner}@#{domain}:#{shared_path}/config/config.yml"
        run "ln -sf #{shared_path}/config/config.yml #{release_path}/app/config/config.yml"
    end
end

namespace :passenger do
    desc "Restart Application"
    task :restart do
        run "sudo /etc/init.d/apache2 restart"
    end
end

before "deploy:finalize_update", "deploy:copy_configuration_files"
after "deploy:restart", "deploy:cleanup"
