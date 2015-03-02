class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

	has_one :user_profile, dependent: :destroy, inverse_of: :user
	has_one :user_vk_contacts_collector_permission, dependent: :destroy, inverse_of: :user

	belongs_to :inviter, class_name: 'User', foreign_key: :inviter_id

	has_many :user_vk_contacts_records, inverse_of: :user, dependent: :destroy

	has_many :referrals, class_name: 'User', foreign_key: :inviter_id

	has_many :user_referral_payments, dependent: :destroy

	accepts_nested_attributes_for :user_vk_contacts_collector_permission
	accepts_nested_attributes_for :user_profile

	validates :referral_earned, :referral_paid_out, numericality: { greater_than_or_equal_to: 0 }
	validates :referral_award_level_1, :referral_award_level_2, numericality: {
			greater_than_or_equal_to: 0,
			less_than_or_equal_to: 50
		}

	alias_method :vcc_permission, :user_vk_contacts_collector_permission
	alias_method :profile, :user_profile


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
					_build_user_vk_contacts_collector_permission
					_set_as_admin
					_set_inviter_id
					_set_referral_award
				end

				private

				def _build_user_profile
					user.build_user_profile
				end

				def _build_user_vk_contacts_collector_permission
					user.build_user_vk_contacts_collector_permission
				end

				def _set_as_admin
					user.is_admin = true if User.count.zero?
				end

				def _set_inviter_id
					unless User.count.zero?
						user.inviter_id = UserProfile.where(INVITE_CODE_FIELD => user.invite_code).take(1).first.user_id
					end
				end

				def _set_referral_award
					user.referral_award_level_1 = 45
					user.referral_award_level_2 = 30
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
				unless User.count.zero?
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

		module Functions
			def referral_award_level(level)
				respond_to?("referral_award_level_#{level}") ? send("referral_award_level_#{level}") : 0
			end

			def has_permission?(name, type)
				case type
				when :vk_contacts_collector
					if name.is_a?(Array)
						name.include?(vcc_permission.package.to_sym)
					else
						vcc_permission.package.to_sym == name
					end
				else
					false
				end
			end

			def get_referrals_by(opts = {})
				raise_invalid_args = Proc.new { raise '#referrals_with: invalid args' }
				if opts[:vk_contacts_collector]
					if opts[:vk_contacts_collector][:package_name]
						case opts[:vk_contacts_collector][:package_name]
						when :skilled_120_or_greater
							referrals.joins(:user_vk_contacts_collector_permission).where(user_vk_contacts_collector_permissions: { package: ['skilled_120', 'seasoned_240', 'advanced_360'] })
						when :seasoned_240_or_greater
							referrals.joins(:user_vk_contacts_collector_permission).where(user_vk_contacts_collector_permissions: { package: ['seasoned_240', 'advanced_360'] })
						when :newbie_30, :novice_60, :skilled_120, :seasoned_240, :advanced_360
							referrals.joins(:user_vk_contacts_collector_permission).where(user_vk_contacts_collector_permissions: { package: opts[:vk_contacts_collector][:package_name] })
						else
							raise_invalid_args.call()
						end
					else
						raise_invalid_args.call()
					end
				else
					raise_invalid_args.call()
				end
			end
		end
	end

	include Extensions::DeviseSignUp
	include Extensions::Functions
end
