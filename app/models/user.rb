class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[bitbucket]

  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_create do |user|
      user.avatar = auth['extra']['links']['avatar']['href']
      user.access_token = auth['credentials']['token']
      user.email = auth['info']['email']
      user.name = auth['info']['name']
      user.refresh_token = auth['credentials']['refresh_token']
      user.token_expiration_time = DateTime.now + auth['credentials']['expires_in'].to_i.seconds
      user.username = auth['info']['username']
    end
  end

  def refresh_token!
    response = Faraday.post(
      'https://bitbucket.org/site/oauth2/access_token',
      {
        grant_type: 'refresh_token',
        refresh_token: refresh_token,
        client_id: Rails.application.credentials.bitbucket.client_key,
        client_secret: Rails.application.credentials.bitbucket.client_secret
      }
    )

    token_data = JSON.parse(response.body)

    self.access_token = token_data['access_token']
    self.token_expiration_time = DateTime.now + token_data['expires_in'].to_i.seconds
  end

  def repository(repo_name)
    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
  end

  def branches(repo_name)
    JSON.parse(
      Faraday.get(
        "https://api.bitbucket.org/2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/refs/branches",
        nil,
        { 'Authorization': "Bearer #{access_token}" }
      ).body
    )
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

  def time_now_plus_duration(duration)
    Datetime.now + duration.seconds
  end
end
