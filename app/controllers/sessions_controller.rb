class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    user = User.find_by_provider_and_uid(auth['provider'], auth['uid']) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    session[:access_token] = auth.credentials.token

    redirect_to root_url, notice: 'Signed in!'
  end

  def choose_repo
    session[:selected_repository] = params[:repository]
    session[:selected_priority] = params[:priority]
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'Signed out!'
  end

  def failure
    @message = params[:message]
  end
end
