set :repo_url,        'git@github.com:raksharuby10/third_party.git'
set :application,     'third_party'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    6
# Don't change these unless you know what you're doing
set :pty,             false
set :use_sudo,        false
set :rvm_ruby_string, '2.6.5' # you probably have this already
set :deploy_via,      :remote_cache
# set :deploy_via, :remote_cache
set :deploy_to,       "var/deploy/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to false when not using ActiveRecord
set :bundle_flags, '--deployment'
set :repository_cache, "git_cache"
# set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }
# set :sidekiq_config, "#{current_path}/config/sidekiq.yml"

## Defaults:
# set :scm,           :git
set :branch,        :main
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5
## Linked Files & Directories (Default None):
# set :linked_files, %w{.env}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
append :linked_dirs,  "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", "public/system", "bundle"

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
end
# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma