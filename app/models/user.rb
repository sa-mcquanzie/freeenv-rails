class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[bitbucket]

  def self.from_omniauth(auth)
    puts auth
    where(uid: auth.uid).first_or_create do |user|
      user.avatar = auth['extra']['links']['avatar']['href']
      user.access_token = auth['credentials']['token']
      user.email = auth['info']['email']
      user.name = auth['info']['name']
      user.refresh_token = auth['credentials']['refresh_token']
    end
  end
end
