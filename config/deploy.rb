# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'the_new_friends'

# GIT settings
set :scm, :git
set :repo_url, 'git@example.com:me/my_repo.git'

# Deploy user setting
# set :deploy_user, 'deploy'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/home/%s/apps/%s' % [fetch(:deploy_user), fetch(:application)]

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Setup rbenv.
set :rbenv_type, :user
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}


namespace :deploy do
	after :restart, :clear_cache do
		on roles(:web), in: :groups, limit: 3, wait: 10 do
			# Here we can do anything such as:
			# within release_path do
			#   execute :rake, 'cache:clear'
			# end
		end
	end
end
