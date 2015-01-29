if Rails.env.development?
	Sidekiq.configure_server do |config|
		config.redis = { url: 'redis://redistogo:0fac379daadff2194f8e0b2fbaffc81d@dab.redistogo.com:9835' }
	end

	Sidekiq.configure_client do |config|
		config.redis = { url: 'redis://redistogo:0fac379daadff2194f8e0b2fbaffc81d@dab.redistogo.com:9835' }
	end
elsif Rails.env.production?
	raise "ENV['REDISTOGO_URL'] is nil" if ENV['REDISTOGO_URL'].nil?

	current_web_concurrency = Proc.new do
		web_concurrency = ENV['WEB_CONCURRENCY']
		web_concurrency ||= Puma.respond_to?(:cli_config) && Puma.cli_config.options.fetch(:max_threads)
		web_concurrency || 2
	end

	ENV['REDISTOGO_URL'] ||= local_redis_url.call

	Sidekiq.configure_server do |config|
		config.redis = { url: ENV['REDISTOGO_URL'], namespace: 'thenewfriends' }

		Rails.application.config.after_initialize do
			ActiveRecord::Base.connection_pool.disconnect!

			ActiveSupport.on_load(:active_record) do
				config = Rails.application.config.database_configuration[Rails.env]
				config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
				config['pool'] = ENV['WORKER_DB_POOL_SIZE'] || Sidekiq.options[:concurrency]
				ActiveRecord::Base.establish_connection(config)

				Rails.logger.info("Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
			end
		end
	end

	Sidekiq.configure_client do |config|
		config.redis = { url: ENV['REDISTOGO_URL'], namespace: 'thenewfriends', :size => 1 }

		Rails.application.config.after_initialize do
			ActiveRecord::Base.connection_pool.disconnect!

			ActiveSupport.on_load(:active_record) do
				config = Rails.application.config.database_configuration[Rails.env]
				config['reaping_frequency'] = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
				config['pool'] = ENV['WEB_DB_POOL_SIZE'] || current_web_concurrency.call
				ActiveRecord::Base.establish_connection(config)

				# DB connection not available during slug compliation on Heroku
				Rails.logger.info("Connection Pool size for web server is now: #{config['pool']}")
			end
		end
	end

	# Sidekiq.configure_server do |config|
	# 	config.redis = { url: 'redis://redistogo:0fac379daadff2194f8e0b2fbaffc81d@dab.redistogo.com:9835' }
	#
	# 	if defined?(ActiveRecord::Base)
	# 		ActiveRecord::Base.establish_connection(
	# 			Rails.application.config.database_configuration[Rails.env]
	# 		)
	# 	end
	# end
	#
	# Sidekiq.configure_client do |config|
	# 	config.redis = { url: 'redis://redistogo:0fac379daadff2194f8e0b2fbaffc81d@dab.redistogo.com:9835' }
	# end
else
	# some code
end