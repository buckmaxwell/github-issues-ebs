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

		@boxplots = []
		@milestones.each do |ms|
			unless ms.nil?
				@boxplots << get_box_and_whisker(ms)
			end
		end

		#ds = RailsDataExplorer::DataSet.new([0.5,0.9,1, 0.3, 0.3], 'Example Chart')
		#@rde = RailsDataExplorer::Chart::BoxPlot.new(ds)

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

		def get_box_and_whisker(milestone)
			#puts milestone.rels[:lables]
			issues = @client.issues(nil, {:per_page => 100, :state => :open, :milestone => milestone.number })
			issues = paginate(issues, 100, 10000)

			issues.each do |i|
				puts i.title
			end
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
			issues = paginate(issues, 100, 500)


			#next_url = @client.last_response.rels[:next]
			

			#continue = issues.length == 100
			#while issues.length < 500 and continue
			#	new_data = @client.last_response.rels[:next].get.data
			#	issues.concat new_data
			#	continue = new_data.length == 100
			#end

			issues.each do |issue|
				v = get_velocity(issue)
				unless v.nil?
					result << v
				end
			end
			result
		end

		def paginate(page1_result, per_page, max)
			result = page1_result
			continue = result.length == per_page
			while result.length < max and continue
				puts 'requing'
				#new_data = @client.last_response.rels[:next].get.data
				new_data = @client.get @client.last_response.rels[:next].href
				result.concat new_data
				continue = new_data.length == per_page
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


# Google Charts Info

#https://chart.googleapis.com/chart?chs=400x225&cht=ls&chd=t0:-1,5,5,10,7,12,-1|-1,25,25,30,27,24,-1|-1,40,40,45,47,39,-1|-1,55,55,63,59,80,-1|-1,30,30,40,35,30,-1|-1,-1,-1,-1,-1,-1,-1|-1,-1,-1,-1,-1,-1,-1&chm=F,FF9900,0,1:5,40|H,0CBF0B,0,1:5,1:20|H,000000,4,1:5,1:40|H,0000FF,3,1:5,1:20|o,FF0000,5,-1,7|o,FF0000,6,-1,7&chxt=y,x&chdl=Outliers|Max+Value|Candlestick|Median|Min+Value&chco=FF0000,0000FF,FF9900,000000,0CBF0B&chl=fuck1|fuck2|fuck3|fuck4|fuck5


# all series bounded by -1
# first series is minimum values
# second series is 25%
# 3rd is 75%
# 4th is Maximum value
# 5th is Median line
# 6th is Outlier Data 1
# 7th is Outlier Data 2
# More Outlier Data can be added if needed






