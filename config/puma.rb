_threads_count = Integer(ENV['MAX_THREADS'] || 5)

threads _threads_count, _threads_count
workers Integer(ENV['WEB_CONCURRENCY'] || 2)

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 3000
environment ENV['RACK_ENV'] || 'development'

GC.respond_to?(:copy_on_write_friendly=) and (GC.copy_on_write_friendly = true)

on_worker_boot do
	if defined?(ActiveRecord)
		ActiveRecord::Base.connection_pool.disconnect!
	end

	# if ENV['NUM_SIDEKIQ_WORKERS'].to_i > 0
	jobs = {
		worker_1: (@worker_1_pid ||= Process.spawn("bundle exec sidekiq -c 2}"))
	}

	jobs.each do |name, pid|
		t = Thread.new {
			Process.wait(pid)
			puts "#{name} died. Bouncing puma."
			Process.kill 'QUIT', Process.pid
		}
		# Just in case
		t.abort_on_exception = true
	end
	# end

	if defined?(ActiveRecord)
		if Rails.application.config.database_configuration
			config = Rails.application.config.database_configuration[Rails.env]
			config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
			config['pool'] = ENV['MAX_THREADS'] || 5
			ActiveRecord::Base.establish_connection(config)
		end
	end
end