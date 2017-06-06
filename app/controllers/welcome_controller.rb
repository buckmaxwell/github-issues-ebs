class WelcomeController < ApplicationController

	# Users must be logged in to see views associated with this controller
	before_action :authorize

	def index

		@velocity_history = get_past_velocities
		puts @velocity_history

		#@repos = octokit_client.repos[3].inspect
		#puts @repos
	end

	private

		def get_past_velocities
			result = []
			# Used as a prefix for photos and images
			octokit_client = Octokit::Client.new(
				:access_token => access_token
			)
			# Get Past Velocities
			issues = octokit_client.issues(nil, {:per_page => 100, :state => :closed })
			#next_url = octokit_client.last_response.rels[:next]
			continue = issues.length == 100
			while issues.length < 500 and continue
				new_data = octokit_client.last_response.rels[:next].get.data
				issues.concat new_data
				continue = new_data.length == 100
			end

			issues.each do |issue|
				v = get_velocity(issue)
				unless v.nil?
					result << v
				end
			end
			result
		end

		def get_velocity(issue)
			unless issue.body.blank?
				body = issue.body.downcase
				est = body.split('@estimate:')[-1].split('h')[0] #=> "1" or "20" or "adad sdfs  d"
				act = body.split('@actual:')[-1].split('h')[0] #=> "1" or "20" or "adad sdfs  d"
				
				if is_numeric? est and is_numeric? act
					est.to_f / act.to_f
				end
			else
				nil
			end
			# Alternative for getting comments
			#comment1 = issue.rels[:comments].get(:uri => {:number => 1}).data[0]
		end

		def is_numeric?(string)
			string.to_i.to_s == string
		end
end
