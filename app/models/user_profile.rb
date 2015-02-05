class UserProfile < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_profile

	validates :first_name, :last_name, :skype, presence: true, if: Proc.new { |obj| !obj.new_record? }
end