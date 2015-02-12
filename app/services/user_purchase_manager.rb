class UserPurchaseManager
	attr_reader :user

	def initialize(user)
		@user = user
	end

	def buy_vk_contacts_collector(package_name)
		unless (package = UserVkContactsCollectorPermission.get_package_by(:name, package_name.to_sym)).nil?
			ActiveRecord::Base.transaction do
				permit_vk_contacts_collector(package[:name])
				pay_the_inviter(package[:price])
				calculate_referral_awards_of_the_inviter
			end
		end
	end

	def permit_vk_contacts_collector(package_name)
		UserPermissionManager.new(user).permit(:vk_contacts_collector, package_name: package_name)
	end

	def pay_the_inviter(package_price)
		UserReferralManager.new(user).pay_the_inviter(package_price)
	end

	def calculate_referral_awards_of_the_inviter
		UserReferralManager.new(user.inviter).calculate_referral_awards unless user.inviter.nil?
	end
end