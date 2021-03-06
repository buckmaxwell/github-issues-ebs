Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "welcome#index"

  get "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure" => "sessions#failure"

  get "/update_velocities" => 'welcome#update_velocities'
  get "/about" => 'welcome#about'
  post '/choose_repo' => "sessions#choose_repo"
  get "/signin" => "users#new"
  get "/signout" => "sessions#destroy", :as => :signout

end

