require File.expand_path '../boot', File.dirname(__FILE__)
require File.expand_path '../environment', File.dirname(__FILE__)

module Clockwork
	handler do |job|
		# some code
	end

	every(24.hours, 'frequent.job')
end