require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class HomeController < ApplicationController
  before_action :authenticate_user!, :refresh_token_if_expired!, :connect_to_bitbucket

  def index
  end

  private

  def refresh_token_if_expired!
    return unless DateTime.current.after?(current_user.token_expiration_time)

    current_user.refresh_token!
  end

  def connect_to_bitbucket
    @bitbucket_connection = Faraday.new(
      url: 'https://api.bitbucket.org/2.0',
      headers: { 'Authorization': "Bearer #{current_user.access_token}" }
    ) { |conn| conn.request :url_encoded }
  end
end
