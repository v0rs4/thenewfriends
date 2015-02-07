class AddVkUrlAndOkUrlAndFbUrlYoutubeChanelUrlAndGooglePlusUrlToUserProfiles < ActiveRecord::Migration
	def up
		add_column :user_profiles, :vk_url, :string
		add_column :user_profiles, :facebook_url, :string
		add_column :user_profiles, :odnoklassniki_url, :string
		add_column :user_profiles, :google_plus_url, :string
		add_column :user_profiles, :youtube_chanel_url, :string
	end

	def down
		remove_column :user_profiles, :vk_url
		remove_column :user_profiles, :facebook_url
		remove_column :user_profiles, :odnoklassniki_url
		remove_column :user_profiles, :google_plus_url
		remove_column :user_profiles, :youtube_chanel_url
	end
end
