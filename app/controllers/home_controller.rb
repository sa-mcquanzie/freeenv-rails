require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class HomeController < ApplicationController
  before_action :authenticate_user!, :refresh_token_if_expired!, :connect_to_bitbucket

  def index
    @data = branches('test-roh-repo')
    # @data = nil
  end

  private

  def refresh_token_if_expired!
    return unless current_user.token_expiration_time.past?

    current_user.refresh_token!
  end

  def connect_to_bitbucket
    @bitbucket_connection = Faraday.new url: 'https://api.bitbucket.org' do |connection|
      connection.authorization :Bearer, current_user.access_token
      connection.request :url_encoded
    end
  end

  
  def repository(repo_name)
      response = @bitbucket_connection.get("2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}")
      JSON.parse(response.body)
  end

  def branches(repo_name)
    response = @bitbucket_connection.get(
      "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/refs/branches"
    )
    JSON.parse(response.body).to_h['values'].map { |branch| branch['name'] }
  end

  def tagged_commit(repo_name, tag_name)
    refresh_token!

    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/refs/branches",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
  end

  def workspaces
    Faraday.get("https://api.bitbucket.org/2.0/workspaces/#{Rails.application.credentials.bitbucket.workspace_name}").body
  end
end
