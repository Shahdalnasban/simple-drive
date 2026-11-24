class HealthController < ApplicationController
  def show
    render json: { status: "ok", message: "Simple Drive API is running" }
  end
end
