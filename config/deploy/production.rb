set :stage, :production
set :rails_env, :production

set :branch, :master

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

set :deploy_user, 'vagrant'
set :deploy_to, '/home/%s/apps/%s' % [fetch(:deploy_user), fetch(:full_app_name)]

set(:app_config_files, [
		"shared/config/nginx.conf.erb",
		"shared/config/database.yml.erb",
		"shared/config/sidekiq.yml.erb",
		"shared/config/unicorn.rb.erb"
	]
)
set(:app_config_symlinks, [
		{
			source: "#{shared_path}/config/nginx.conf",
			destination: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}.conf"
		}
	]
)

set :unicorn_worker_count, 5
set :unicorn_timeout, 60

set :nginx_server_name, 'the_new_friends.remote'
set :nginx_enable_ssl, false


# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db, %w{deploy@example.com}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

# server 'example.com', user: 'deploy', roles: %w{web app db}
server '127.0.0.1', user: 'vagrant', roles: %w{web app db}, ssh_options: {
		user: 'vagrant',
		keys: ['/Users/broderickbrockman/Work/rails_deployment_test/rails-server-template/.vagrant/machines/rails-postgres-redis1/virtualbox/private_key'],
		port: 2222
	}


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
