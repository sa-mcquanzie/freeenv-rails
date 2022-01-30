require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class HomeController < ApplicationController
  before_action :authenticate_user!, connect_to_bitbucket

  def index
  end

  private

  def connect_to_bitbucket
    @bitbucket_connection = Faraday.new(
      url: 'https://api.bitbucket.org/2.0',
      headers: { 'Authorization': "Bearer #{current_user.access_token}" }
    ) { |conn| conn.request :url_encoded }
  end
end
