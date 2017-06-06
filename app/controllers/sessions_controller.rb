class SessionsController < ApplicationController
	def create     
		auth = request.env["omniauth.auth"]
		#puts 'YO'
		#puts auth.credentials.token
		#puts 'YO'

		#client = Octokit::Client.new(:access_token => auth.credentials.token)

		#puts 'uhh'
		#puts client.user.fields.to_a
		#puts 'uhh'


		user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
		session[:user_id] = user.id
		session[:access_token] = auth.credentials.token
		
		redirect_to root_url, :notice => "Signed in!"
  	end

  	def destroy
    	session[:user_id] = nil
    	redirect_to root_url, :notice => "Signed out!"
  	end

end

