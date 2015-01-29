class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

	has_one :user_profile, dependent: :destroy, inverse_of: :user
	has_one :user_permission, inverse_of: :user
	has_many :user_vk_contacts_files, dependent: :destroy, inverse_of: :user

	accepts_nested_attributes_for :user_permission, allow_destroy: true
	accepts_nested_attributes_for :user_profile, allow_destroy: true

	module Extensions
		module DeviseSignUp
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
				end

				private

				def _build_user_profile
					user.build_user_profile
				end

				def _build_user_permission
					user.build_user_permission
				end
			end

			included do
				# validate :some_method, if: Proc.new { new_record? }
				before_create do
					DepsInitializer.new(self).run
				end
			end
		end
	end

	include Extensions::DeviseSignUp
end
