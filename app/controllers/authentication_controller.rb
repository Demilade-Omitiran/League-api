class AuthenticationController < ApplicationController
  before_action :authenticate_user_from_headers!, only: [:logout]
  before_action :set_user, only: [:logout]

  def register
    user = User.create(user_create_params)

    if user.save
      sign_in user, store: false

      token = JwtService.encode({user_id: user.id})
      user.update_attribute(:valid_jwt, token)

      response_data = { id: user.id, email: user.email, auth_token: token }
      return global_json_render(201, "Registration successful", response_data)
    end
    return global_error_render(400, "Registration unsuccessful", user.errors)
  end

  def login
    user = User.find_for_database_authentication(email: params[:email])

    if user && user.valid_for_authentication?{ user.valid_password?(params[:password]) }
      sign_in user, store: false
      
      token = JwtService.encode({user_id: user.id})
      user.update_attribute(:valid_jwt, token)
      response.headers['auth_token'] = token

      data = {
        auth_token: token, 
        user: { 
          id: user.id, 
          email: user.email 
        }
      }

      global_json_render(200, "User login successful", data)
    else
      message = "Invalid login details"

      global_error_render(401, message)
    end
  end

  def logout
    @user.update_attribute(:valid_jwt, nil)
    sign_out @user

    global_json_render(200, "Logout successful")
  end

  private
  def set_user
    @user = current_user
  end

  def user_create_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
