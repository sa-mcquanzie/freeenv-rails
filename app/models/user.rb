class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[bitbucket]

  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_create do |user|
      user.avatar = auth['extra']['links']['avatar']['href']
      user.access_token = auth['credentials']['token']
      user.email = auth['info']['email']
      user.name = auth['info']['name']
      user.refresh_token = auth['credentials']['refresh_token']
      user.username = auth['info']['username']
    end
  end

  #   self.access_token = JSON.parse(response.body)['access_token']
  # end
  # def token_expired?(connection)
  #   connection
  #     .get("/workspaces/#{ENV['WORKSPACE_NAME']}")
  #     .body
  #     .to_s
  #     .include? 'Access token expired'
  # end

  def refresh_token!
    response = Faraday.post(
      'https://bitbucket.org/site/oauth2/access_token',
      {
        grant_type: 'refresh_token', refresh_token: refresh_token,
        client_id: ENV['BITBUCKET_CLIENT_KEY'], client_secret: ENV['BITBUCKET_CLIENT_SECRET']
      }
    )

    token_data = JSON.parse(response.body)

    self.access_token = token_data['access_token']
  end

  def repository(repo_name)
    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{ENV['WORKSPACE_NAME']}/#{repo_name}",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
  end

  def branches(repo_name)
    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{ENV['WORKSPACE_NAME']}/#{repo_name}/refs/branches",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
  end

  def tagged_commit(repo_name, tag_name)
    refresh_token!

    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{ENV['WORKSPACE_NAME']}/#{repo_name}/refs/branches",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
  end

  def workspaces
    Faraday.get("https://api.bitbucket.org/2.0/workspaces/#{ENV['WORKSPACE_NAME']}").body
  end
end
