require "test_helper"

# Tests authentication through real API requests
class AuthenticationTest < ActionDispatch::IntegrationTest
  # Checks that a request without a token is rejected
  test "request without bearer token is rejected" do
    get "/health"

    assert_response :unauthorized
  end

  # Checks that a request with the correct token is accepted
  test "request with bearer token is accepted" do
    get "/health", headers: {
      "Authorization" => "Bearer #{ENV.fetch("API_TOKEN")}"
    }

    assert_response :success
  end
end
