class WelcomeController < ApplicationController

	# Users must be logged in to see views associated with this controller
	before_action :authorize

	def index

		# Temporarily commented out
		#@velocity_history = get_velocity_history
		@client = Octokit::Client.new(
				:access_token => access_token
		)
		@repos = get_repos
		@selected_repo = get_selected_repo

		@milestones = get_milestones(@selected_repo)

		#@repos = @client.repos[3].inspect
		#puts @repos
	end

	def choose_repos
		puts params[:repos]
	end

	private

		def get_selected_repo
			unless selected_repository.nil?
				selected_repository
			else
				@repos[0]
			end
		end

		def get_repos
			repos = @client.repos(nil, {:per_page => 100, :state => :closed })
			#next_url = @client.last_response.rels[:next]
			continue = repos.length == 100
			while repos.length < 500 and continue
				new_data = @client.last_response.rels[:next].get.data
				repos.concat new_data
				continue = new_data.length == 100
			end
			new_repos = []
			repos.each do |repo|
				new_repos << repo.full_name
			end
			new_repos
		end

		def get_milestones(repo_name)
			milestones = @client.milestones(repo_name, {:per_page => 100, :state => :open })
		end

		def get_ship_date(milestone)
			issues = @client.milestones(nil, {:per_page => 100, :state => :open })

		end

		def get_velocity_history
			result = []
			result = get_past_velocities

			# We assume the worst about the users prediction ability until they
			# prove otherwise
			if result.length < 6
				result = [0.5, 1.7, 0.2, 1.2, 0.9, 13.0]
			end
			result
		end

		def get_past_velocities
			result = []
			
			# Get Past Velocities
			issues = @client.issues(nil, {:per_page => 100, :state => :closed })
			#next_url = @client.last_response.rels[:next]
			continue = issues.length == 100
			while issues.length < 500 and continue
				new_data = @client.last_response.rels[:next].get.data
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
