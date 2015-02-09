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
			#nothing
		end
	end

	private

	def _permit_vk_contacts_collector(opts = {})
		user.user_permission.update_attributes(
			user_vk_contacts_files_create: true,
			user_vk_contacts_files_read: true,
			user_vk_contacts_files_update: true
		)
	end
end