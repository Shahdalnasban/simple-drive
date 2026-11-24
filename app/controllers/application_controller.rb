class ApplicationController < ActionController::API
  # Run this security check before every API request
  before_action :authenticate_request!

  private

  # Checks whether the user sent the correct Bearer token
  def authenticate_request!
    # Read the Authorization header sent with the request
    authorization_header = request.headers["Authorization"].to_s

    # Remove the word "Bearer" and keep only the token
    token = authorization_header.delete_prefix("Bearer ").strip

    # Allow the request only if the token matches the private .env token
    return if ActiveSupport::SecurityUtils.secure_compare(token, ENV.fetch("API_TOKEN"))

    # Otherwise, reject the request
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end