class UserPermission < ActiveRecord::Base
	belongs_to :user, inverse_of: :user_permission
end
