class ApplicationController < ActionController::Base
  	protect_from_forgery with: :exception
  	

  
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	helper_method :current_user

	def access_token
		@access_token = session[:access_token]
	end

	def selected_repository
		@selected_repository = session[:selected_repository]
	end

	def authorize
    	redirect_to '/signin' unless current_user
  	end


end
