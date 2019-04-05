Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # root to: "application#index"

  # Auth
  post '/register', to: "authentication#register"
  post '/login', to: "authentication#login"
  post '/logout', to: "authentication#logout"
  post '/update_password', to: "authentication#update_password"

  # Users
  get '/users', to: "users#index"
  get '/users/:user_id', to: "users#show"
  get '/user', to: "users#show_user"
  post '/user/update', to: "users#update"

  # Teams
  resources :teams, except: [:edit, :new], param: :team_id

end
