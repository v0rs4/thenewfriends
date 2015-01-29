class CreateUserProfiles < ActiveRecord::Migration
	def up
		create_table :user_profiles do |t|
			t.integer :user_id, null: false
			t.string :first_name
			t.string :last_name
			t.text :about
			t.string :country
			t.string :city
			t.string :skype
			t.string :contact_phone
			t.string :contact_email
			t.string :vkontakte_id
			t.string :facebook_id
			t.string :twitter_id
			t.timestamps
		end

		add_index :user_profiles, :user_id, unique: true, name: :user_profiles_user_id_unique
	end

	def down
		drop_table :user_profiles
		remove_index :user_profiles, name: :user_profiles_user_id_unique
	end
end
