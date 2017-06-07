class WelcomeController < ApplicationController

	# Users must be logged in to see views associated with this controller
	before_action :authorize

	def index

		# Temporarily commented out
		#@velocity_history = get_velocity_history

		Octokit.configure do |c|
			c.access_token = access_token
		end

		@client = Octokit::Client.new(
				:access_token => access_token
		)
		@repos = get_repos
		@selected_repo = get_selected_repo

		@milestones = get_milestones(@selected_repo)


		@priority_labels = [
			['Urgent only', 'urgent'],
			['High or Urgent', 'urgent,high'],
			['Important or higher', 'urgent,high,important'],
			['Medium or higher', 'urgent,high,important,medium'],
			['Moderate or greater', 'urgent,high,important,moderate'],
			['Low or higher', 'urgent,high,important,moderate,low'],
			['All features', 'urgent,high,important,moderate,low,none']
		]
		@selected_priority = get_selected_priority
		@boxplots = []
		@data_stores = []
		@shipping_prob = []
		@milestones.each do |ms|
			unless ms.nil?
				#@boxplots << get_box_and_whisker(ms)
				ds = get_data_store(ms)
				@data_stores << ds
				@boxplots << get_box_plot_data(ds)
				@shipping_prob << get_probability_of_shipping_by_hours(ds)
			end
		end

		#update_past_velocities

		#ds = RailsDataExplorer::DataSet.new([0.5,0.9,1, 0.3, 0.3], 'Example Chart')
		#@rde = RailsDataExplorer::Chart::BoxPlot.new(ds)

		#@repos = @client.repos[3].inspect
		#puts @repos
	end

	def update_velocities
		# Do this asynchronously
		puts 'asynchronously updating past velocities...'
		Thread.new do
			update_past_velocities
			ActiveRecord::Base.connection.close 
		end
		redirect_to root_url, :notice => "Asynchronously updating past velocities..."
	end

	def choose_repos
		#puts params[:repos]
	end

	private

		def get_selected_priority
			unless selected_priority.nil?
				selected_priority
			else
				@priority_labels[-1]
			end
		end

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

		def get_data_store(milestone)
			#puts milestone.rels[:lables]

			data_store = {}
			# {'buckmaxwell':{:sample_futures => [sf1,sf2,...,sf100],
			#			  	  :max => 217, :min => 103
			#  				 },
			#  'erikthiem':{:sample_futures:[sf1,sf2,...,sf100], :max:217, :min:103},
			# }

			# Sample Future (sf1) example [6.7, 16, 3.3, 13.3, 32].sum => 71.3}
			# 

			# Imperfect - a request must be made between 1 and 7 times
			issues = []
			repo_name = milestone.url.split('/repos/')[1].split('/milestones')[0]
			@selected_priority.split(',').each do |label|
				#puts label
				issues_for_label = Octokit.issues(repo_name, {:per_page => 100, :state => :open, :milestone => milestone.number, :assignee => '*', :labels => label })
				issues_for_label = paginate(issues_for_label, 100, 10000)
				issues.concat issues_for_label
			end
			

			# Populate Data Store
			100.times do |x|
				# Create a sample future for each collab
				sfs = {} # => {'buckmaxwell': [], 'erikthiem': []} 
				collab_name = ''
				issues.each do |issue|
					if sfs[issue.assignee.login].nil?
						sfs[issue.assignee.login] = []
					end
					issue_est = get_estimate(issue)
					sfs[issue.assignee.login] <<  issue_est unless issue_est.nil?
					if sfs[issue.assignee.login].empty?
						 sfs.delete(issue.assignee.login)
					end
				end

				sfs.keys.each do |login|
					
					if data_store[login].nil?
						data_store[login] = {
						 	:sample_futures => [],
						 	:max => sfs[login].sum,
						 	:min => sfs[login].sum
						}
						puts data_store
					end
					#puts data_store
					#puts data_store[login][:sample_futures]
					data_store[login][:sample_futures] << sfs[login].sum
					data_store[login][:max] = [data_store[login][:max], sfs[login].sum ].max
					data_store[login][:min] = [data_store[login][:min], sfs[login].sum ].min
				end
			end
			data_store
			#url = get_google_boxplot(data_store)
			#puts url
			#url
		end

		def get_probability_of_shipping_by_hours(data_store)
			# [[percent_likely,hours],[1,3],[4,15],[5,16], etc.]
			result = []
			unless data_store.keys.length < 1
				tmax = 0 # true maximum
				critical_dev = '' # the developer who has the tmax
				data_store.keys.each do |login|
					old_tmax = tmax
					tmax = [data_store[login][:max],old_tmax].max
					if old_tmax < tmax
						critical_dev = login
					end
				end

				100.times do |percent|
					# get shipping probability
					hour = data_store[critical_dev][:sample_futures].percentile(percent)
					result << [hour, percent]
				end
				puts result.to_s
			end
			result
		end

		def get_box_plot_data(data_store)
			result = []
			data_store.keys.each do |login|
				row = []
				sfs = data_store[login][:sample_futures]
				row << login # column label
				2.times do |x|
					row << sfs.max.round(1)
					row << sfs.min.round(1)
					row << sfs.percentile(25).round(1)
					row << sfs.percentile(50).round(1)
					row << sfs.percentile(75).round(1)
				end
				result << row
			end
			result
		end

		def update_past_velocities
			pv = get_velocity_history
			pv.keys.each do |login|
				collab = Collaborator.find_by_login(login)
				history = pv[login]
				if collab.nil?
					collab = Collaborator.new(:login => login, :history => history)
				else
					collab.history = history
				end
				collab.save
			end
		end

		def get_velocity_history
			result = get_past_velocities

			# We assume the worst about the users prediction ability until they
			# prove otherwise
			result.keys.each do |login|
				if result[login].length < 6
					result[login] = [0.5, 1.7, 0.2, 1.2, 0.9, 13.0]
				end
			end
			
			result
		end

		def get_past_velocities
			result = {}
			
			# Get Past Velocities
			
			# Just current client issues
			#issues = @client.issues(nil, {:per_page => 100, :state => :closed })
			
			# All issues the logged in user can see
			issues = Octokit.issues(nil, {:per_page => 100, :state => :closed, :filter => :all})
			issues = paginate(issues, 100, 500)


			#next_url = @client.last_response.rels[:next]
			

			#continue = issues.length == 100
			#while issues.length < 500 and continue
			#	new_data = @client.last_response.rels[:next].get.data
			#	issues.concat new_data
			#	continue = new_data.length == 100
			#end

			issues.each do |issue|
				unless issue.assignee.nil?
					v = get_velocity(issue)
					unless v.nil?
						if result[issue.assignee.login].nil?
							result[issue.assignee.login] = []
						end
						result[issue.assignee.login] << v
					end
				end
			end
			result
		end

		def paginate(page1_result, per_page, max)
			result = page1_result
			continue = result.length == per_page
			while result.length < max and continue
				#new_data = @client.last_response.rels[:next].get.data
				new_data = Octokit.get Octokit.last_response.rels[:next].href
				result.concat new_data
				continue = new_data.length == per_page
			end
			result
		end


		def get_estimate(issue)
			unless issue.body.blank? or issue.assignee.nil?
				collab = Collaborator.find_by_login(issue.assignee.login)
				body = issue.body.downcase
				initial_est = body.split('@estimate:')[-1].split('h')[0] #=> "1" or "20" or "adad sdfs  d"
				if is_numeric? initial_est
					initial_est.to_f / collab.random_velocity
				end
			else
				nil
			end
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

# https://developers.google.com/chart/interactive/docs/gallery/intervals
# The new box plot




