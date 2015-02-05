class UserProfile < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_profile

	validates :first_name, :last_name, :skype, presence: true, if: Proc.new { |obj| !obj.new_record? }
	validates :username, uniqueness: true, presence: true, format: { with: /\A^[A-z0-9]+\z/ }, if: Proc.new { |obj| !obj.new_record? }
	validates :pm_usd_acct, format: { with: /\AU\d{7}\z/ }, if: Proc.new { |obj| !obj.new_record? }
end