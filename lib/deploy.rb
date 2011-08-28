require 'bundler/capistrano'
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"

set :rvm_ruby_string, '1.9.2-p290@backoffice'
set :rvm_type, :user

default_run_options[:pty] = true

set :user, 'capistrano'
set :application, 'jupiter'
set :domain, 'backup.arbousier.info'

#set :use_sudo, true
set :deploy_to, "/var/www/backoffice/#{application}_production"
set :shared_path, "#{deploy_to}/shared"
set :repository, "git@codeplane.com:mcansky/Jupiter.git"
set :scm, "git"
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa_BO_deploy")]

role :web, "backup.arbousier.info"
role :app, "backup.arbousier.info"
role :db,  "backup.arbousier.info", :primary => true
role :db,  "backup.arbousier.info"

after "deploy:symlink", "deploy:db:symlink"

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{deploy_to}/current/config/unicorn.rb -D -E production #{deploy_to}/current/config.ru"
  end

  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && kill -QUIT `cat #{shared_path}/pids/unicorn-#{application}.pid`"
  end

  task :subdir_setup, :roles => [:web, :app] do
    run "chmod -R 770 #{deploy_to}/shared #{deploy_to}/releases"
    ["pids", "log", "system"].each do |dir|
      run "if [ ! -d #{deploy_to}/shared/#{dir} ]; then mkdir #{deploy_to}/shared/#{dir}; fi"
    end
    run "chmod -R 770 #{deploy_to}/shared #{deploy_to}/releases"
  end

  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
  
  # This will make sure that Capistrano doesn't try to run rake:migrate
  task :clean_cold do
    deploy.stop
    deploy.update
    deploy.subdir_setup
    deploy.start
  end
  task :cold do
    deploy.update
    deploy.subdir_setup
    deploy.start
  end
  namespace :db do
    desc "Create symlink to database.yml in shared folder"
    task :symlink do
      #run "cd #{current_path}/config; rm -f database.yml; ln -nfs #{shared_path}/database.yml"
      #run "cd #{current_path}/public; rm -rf attachments; ln -nfs #{shared_path}/attachments"
    end
  end
end