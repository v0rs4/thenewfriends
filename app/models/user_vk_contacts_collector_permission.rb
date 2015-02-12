class UserVkContactsCollectorPermission < ActiveRecord::Base
	PACKAGES = [
		{
			name: :newbie_30,
			level: 1,
			# price: 10.0,
			price: 0.01,
			duration_in_days: 30,
			requests_limit_per_day: 1
		},
		{
			name: :novice_60,
			level: 2,
			# price: 15.0,
			price: 0.02,
			duration_in_days: 60,
			requests_limit_per_day: 2
		},
		{
			name: :skilled_120,
			level: 3,
			# price: 25.0,
			price: 0.03,
			duration_in_days: 120,
			requests_limit_per_day: 3
		},
		{
			name: :seasoned_240,
			level: 4,
			# price: 45.0,
			price: 0.04,
			duration_in_days: 240,
			requests_limit_per_day: 4
		},
		{
			name: :advanced_360,
			level: 5,
			# price: 80.0,
			price: 0.05,
			duration_in_days: 360,
			requests_limit_per_day: 5
		}
	]

	belongs_to :user, inverse_of: :user_vk_contacts_collector_permission

	validates :package, inclusion: { in: %w(newbie_30 novice_60 skilled_120 seasoned_240 advanced_360) }, allow_blank: true
	validates :expires_at, presence: true, if: Proc.new { !package.blank? }

	before_save do
		if package.blank?
			self.expires_at = nil
			self.can_create = 0
			self.can_read = 0
			self.can_update = 0
			self.can_delete = 0
			self.requests_limit_per_day = 0
		end
	end

	def expired?
		if expires_at.blank?
			true
		else
			Time.zone.now > expires_at
		end
	end

	class << self
		def get_package_by(a, b)
			PACKAGES.find { |p| p[a] == b }
		end
	end
end
