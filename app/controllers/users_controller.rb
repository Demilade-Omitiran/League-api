class UsersController < ApplicationController
  before_action :authenticate_user_from_headers!
  before_action :check_admin!, only: [:show, :index]
  before_action :set_user, except: [:show]

  def update
    if @user.update_attributes(user_update_params)
      global_json_render(200, "User updated successfully", serialized_user(@user))
    else
      global_error_render(400, "Error updating user profile", @user.errors)
    end
  end

  def index
    params[:page] ||= 1
    params[:per_page] ||= 20

    users = User.paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
    data = serialized_users(users)

    counter = User.count # total_entries was problematic
    meta = {
      total: counter,
      per_page: params[:per_page].to_i,
      page: params[:page].to_i,
      page_count: counter.zero? ? 1 : (counter / params[:per_page].to_f).ceil
    }

    global_json_render(200, "Users retrieved successfully", data, meta)
  end

  def show_user
    get_user(@user.id)
  end

  def show
    get_user(params[:user_id])
  end

  private

  def get_user(user_id)
    user = User.find_by(id: user_id)
    return global_error_render(404, "User not found") unless user
    global_json_render(200, "User retrieved successfully", serialized_user(user))
  end

  def user_update_params
    params.permit(:first_name, :last_name)
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
