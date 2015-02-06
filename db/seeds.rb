User.create(email: 'vladislavpauk@gmail.com', password: 'qweasdzxc', password_confirmation: 'qweasdzxzc').tap do |user|
	user.confirm!
end