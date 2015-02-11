class UserVkContactsCollectorPermissionDecorator < Draper::Decorator
	delegate_all

	def expires_in_words
		unless expired?
			h.distance_of_time_in_words(
				Time.zone.now,
				expires_at
			)
		end
	end
end