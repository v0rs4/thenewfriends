class UserPermissionManager
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def permit(p_name, opts = {})
		case p_name
		when :vk_contacts_collector
			_permit_vk_contacts_collector(opts)
		else
			false
		end
	end

	private

	def _permit_vk_contacts_collector(opts = {})
		if (package = UserVkContactsCollectorPermission.get_package_by(:name, opts[:package_name].to_sym)).nil?
			false
		else
			user.vcc_permission.update_attributes!(
				package: package[:name].to_s,
				requests_limit_per_day: package[:requests_limit_per_day],
				can_create: true,
				can_read: true,
				can_update: true,
				expires_at: package[:duration_in_days].days.from_now
			)
		end
	end
end