class String
	def self.generate_rand_seq(length)
		o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
		(0..length).map { o[rand(o.length)] }.join
	end
end