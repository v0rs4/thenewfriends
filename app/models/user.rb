class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

	has_one :user_profile, dependent: :destroy, inverse_of: :user
	has_one :user_permission, inverse_of: :user

	belongs_to :inviter, class_name: 'User', foreign_key: :inviter_id

	has_many :user_vk_contacts_files, dependent: :destroy, inverse_of: :user

	has_many :referrals, class_name: 'User', foreign_key: :inviter_id

	accepts_nested_attributes_for :user_permission, allow_destroy: true
	accepts_nested_attributes_for :user_profile, allow_destroy: true

	validates :referral_earned, :referral_paid_out, numericality: { greater_than_or_equal_to: 0 }
	validates :referral_award, numericality: {
			greater_than_or_equal_to: 0,
			less_than_or_equal_to: 25
		}

	module Extensions
		module DeviseSignUp
			INVITE_MODEL = 'UserProfile'
			INVITE_CODE_FIELD = :username

			extend ActiveSupport::Concern

			class DepsInitializer
				attr_reader :user, :opts

				def initialize(user, opts = {})
					@user = user
					@opts = opts
				end

				def run
					_build_user_profile
					_build_user_permission
					_set_as_admin
					_set_inviter_id
				end

				private

				def _build_user_profile
					user.build_user_profile
				end

				def _build_user_permission
					user.build_user_permission
				end

				def _set_as_admin
					user.is_admin = true if User.count.zero?
				end

				def _set_inviter_id
					user.inviter_id = UserProfile.where(INVITE_CODE_FIELD => user.invite_code).take(1).first.user_id
				end
			end

			included do
				attr_accessor :invite_code
				validate :ensure_invite_code_exists, if: Proc.new { new_record? }
				before_create :initialize_deps
			end

			def initialize_deps
				DepsInitializer.new(self).run
			end

			def ensure_invite_code_exists
				if User.count > 0
					if invite_code.nil?
						add_invite_code_error(:blank)
					else
						add_invite_code_error unless UserProfile.exists?(INVITE_CODE_FIELD => invite_code)
					end
				end
			end

			private

			def add_invite_code_error(message = :invalid)
				singleton_class.send(:attr_reader, :invite_code)
				errors.add(:invite_code, message)
			end
		end
	end

	include Extensions::DeviseSignUp
end
