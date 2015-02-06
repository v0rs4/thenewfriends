CarrierWave.configure do |config|
	config.fog_credentials = {
		provider: 'AWS',
		aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
		aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
		region: ENV['AWS_REGION']
	}

	if Rails.env.test? || Rails.env.cucumber?
		config.storage = :file
		config.enable_processing = false
		config.root = "#{Rails.root}/tmp"
	else
		config.storage = :fog
	end

	# config.cache_dir = "#{Rails.root}/tmp/uploads" # To let CarrierWave work on Heroku
	config.fog_directory = 'tnfdev1'
end