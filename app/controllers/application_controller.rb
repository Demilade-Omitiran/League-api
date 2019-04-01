class ApplicationController < ActionController::API
  def index
    global_json_render(200, "API works")
  end

  protected

  def global_json_render(status, message, data = {}, meta = {})
    json_payload = Hash.new
    json_payload[:message] = message
    if (status == 200 || status == 201)
      json_payload[:data] = data unless data.empty?
      json_payload[:meta] = meta unless meta.empty?
    end

    render json: json_payload, status: status
  end

  def global_error_render(status, message, error)
    json_payload = Hash.new
    json_payload[:message] = message
    json_payload[:errors] = error

    render json: json_payload, status: status
  end
end
