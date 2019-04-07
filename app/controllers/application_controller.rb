class ApplicationController < ActionController::API
  before_action :authenticate_user_from_headers!

  # rescue_from StandardError do |e|
  #   global_error_render(500, "Something went wrong.")
  # end

  protected

  def global_json_render(status, message, data = {}, meta = {}, display_data_if_empty = false)
    json_payload = Hash.new
    json_payload[:message] = message
    if (status == 200 || status == 201)
      if data.empty?
        json_payload[:data] = [] if display_data_if_empty
      else
        json_payload[:data] = data
      end
      json_payload[:meta] = meta unless meta.empty?
    end

    render json: json_payload, status: status
  end

  def global_error_render(status, message, error={})
    json_payload = Hash.new
    json_payload[:message] = message
    json_payload[:errors] = error unless error.empty?

    render json: json_payload, status: status
  end

  private

  def authenticate_user_from_headers!
    return global_error_render(401, "Authorization header not found") unless request.headers && request.headers["HTTP_AUTH_TOKEN"]
    values = request.headers["HTTP_AUTH_TOKEN"].split(" ")
    return global_error_render(401, "Format is Authorization: Bearer [token]") unless values.count == 2 && values.first == "Bearer"

    decoded_auth_token = JwtService.decode(values.last)
    if decoded_auth_token && !decoded_auth_token[:error] && decoded_auth_token["context"] == "user"
      user = User.find_by(id: decoded_auth_token["user_id"])

      return global_error_render(401, "Invalid token") unless user

      if user && user.valid_jwt == values.last
        @current_user ||= user
        response.headers['auth_token'] = values.last
      else
        global_error_render(401, "Invalid token")
      end
    else
      global_error_render(401, "Invalid token")
    end
  end

  def check_admin!
    unless @current_user.admin
      global_error_render(401, "Unauthorized.")
    end
  end
end
