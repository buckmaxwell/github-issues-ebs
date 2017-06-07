class Collaborator < ApplicationRecord

	def random_velocity
		a = JSON.parse self.history
		a.sample.to_f
	end
end
