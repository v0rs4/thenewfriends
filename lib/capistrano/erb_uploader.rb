def erb_upload!(from_path, to_path = nil)
	to_path ||= from_path

	remote_erb_path = "#{shared_path}/#{to_path}"

	if (local_erb_path = erb_file_path(from_path)).nil?
		error "error #{from_path} not found"
	else
		local_erb_path_io = StringIO.new(ERB.new(File.read(local_erb_path)).result(binding))

		upload! local_erb_path_io, remote_erb_path

		info "copying: #{local_erb_path} to: #{remote_erb_path}"
	end
end

def erb_file_path(file_path)
	# if File.exist?((file = "config/deploy/#{fetch(:full_app_name)}/#{file_path}.erb"))
	# 	file
	# elsif File.exist?((file = "config/deploy/shared/#{file_path}.erb"))
	# 	file
	# else
	# 	nil
	# end
	if File.exist?((file = "config/deploy/shared/#{file_path}.erb"))
		file
	else
		nil
	end
end