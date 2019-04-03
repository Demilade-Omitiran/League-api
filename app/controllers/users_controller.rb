class UsersController < ApplicationController
  skip_before_action :authenticate_user_from_headers!, only: [:register, :login]
  before_action :check_admin!, only: [:show, :index]
  before_action :set_user, except: [:register, :login]

  def register
    user = User.create(user_create_params)

    if user.save
      sign_in user, store: false

      token = JwtService.encode({user_id: user.id})
      user.update_attribute(:valid_jwt, token)

      response_data = { id: user.id, email: user.email, auth_token: token }
      return global_json_render(200, "Registration successful", response_data)
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

  def update
    if @user.update_attributes(user_update_params)
      global_json_render(200, "User updated successfully", serialized_user(@user))
    else
      global_error_render(400, "Error updating user profile", @user.errors)
    end
  end

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    # users = User.all.paginate(page: page, per_page: per_page)
    users = User.all.paginate(page: page, per_page: per_page)

    counter = users.total_entries
    meta = {
      total: counter,
      per_page: per_page.to_i,
      page: page.to_i,
      page_count: counter.zero? ? 1 : (counter / per_page.to_f).ceil
    }

    global_json_render(200, "Users retrieved successfully", serialized_users(users), meta)
  end

  def show_user
    get_user(@user.id)
  end

  def show
    get_user(params[:user_id])
  end

  private

  def get_user(user_id)
    user = User.find(user_id)
    global_json_render(200, "User retrieved successfully", serialized_user(user))
  end

  def user_create_params
    params.permit(:first_name, :last_name, :email, :password)
  end

  def user_update_params
    params.permit(:first_name, :last_name, :password)
  end

  def serialized_user(user)
    data = UserSerializer.new(user).serializable_hash
    data.dig(:data, :attributes)
  end

  def serialized_users(users)
    data = UserSerializer.new(users).serializable_hash
    data = data[:data].map do |user|
      user.dig(:attributes)
    end
    data
  end

  def set_user
    @user = current_user
  end
end
