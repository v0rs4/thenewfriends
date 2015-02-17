class Ability
	include CanCan::Ability

	attr_reader :user, :user_d

	def initialize(user)
		@user = user
		@user_d = user.decorate

		_permit_vk_contacts_collector

		# Define abilities for the passed in user here. For example:
		#
		#   user ||= User.new # guest user (not logged in)
		#   if user.admin?
		#     can :manage, :all
		#   else
		#     can :read, :all
		#   end
		#
		# The first argument to `can` is the action you are giving the user
		# permission to do.
		# If you pass :manage it will apply to every action. Other common actions
		# here are :read, :create, :update and :destroy.
		#
		# The second argument is the resource the user can perform the action on.
		# If you pass :all it will apply to every resource. Otherwise pass a Ruby
		# class of the resource.
		#
		# The third argument is an optional hash of conditions to further filter the
		# objects.
		# For example, here the user can only update published articles.
		#
		#   can :update, Article, :published => true
		#
		# See the wiki for details:
		# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
	end

	private

	def _permit_vk_contacts_collector
		u_vcc_p = user.user_vk_contacts_collector_permission
		if u_vcc_p.can_create?
			if u_vcc_p.expires_at > Time.zone.now
				if user_d.vk_contacts_requests_count(:today) < u_vcc_p.requests_limit_per_day
					# can :create, UserVkContactsFile
					can :create, UserVkContactsRecord
				end
			end
		end

		if u_vcc_p.can_read?
			if u_vcc_p.expires_at > Time.zone.now
				# can :read, UserVkContactsFile
				can :read, UserVkContactsRecord
			end
		end

		if u_vcc_p.can_update?
			if u_vcc_p.expires_at > Time.zone.now
				# can :update, UserVkContactsFile
				can :update, UserVkContactsRecord
			end
		end

		if u_vcc_p.can_delete?
			if u_vcc_p.expires_at > Time.zone.now
				# can :delete, UserVkContactsFile
				can :delete, UserVkContactsRecord
			end
		end
	end
end
