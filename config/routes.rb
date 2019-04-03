Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # root to: "application#index"
  post '/register', to: "users#register"
  post '/login', to: "users#login"
  get '/users', to: "users#index"
  get '/users/:user_id', to: "users#show"
  get '/user', to: "users#show_user"
  post '/user/update', to: "users#update"
  post '/logout', to: "users#logout"
end
