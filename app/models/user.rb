class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[bitbucket]

  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_create do |user|
      user.avatar = auth['extra']['links']['avatar']['href']
      user.access_token = auth['credentials']['token']
      user.email = auth['info']['email']
      user.name = auth['info']['name']
      user.refresh_token = auth['credentials']['refresh_token']
      user.token_expiration_time = Time.current + auth['credentials']['expires_in'].to_i.seconds
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

    self.access_token = token_data['access_token'] || access_token
    self.token_expiration_time = Time.current + token_data['expires_in'].to_i.seconds

    save
  end
end
