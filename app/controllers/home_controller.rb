require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    connect_to_bitbucket
    @response = @bitbucket_connection.get.body
  end

  private

  def connect_to_bitbucket
    @bitbucket_connection = Faraday.new(
      url: 'https://api.bitbucket.org/2.0/repositories/sa-mcquanize/dashboard_api_test/refs',
      headers: { 'Authorization': "Bearer {#{current_user.access_token}}>" }
    )
  end
end
