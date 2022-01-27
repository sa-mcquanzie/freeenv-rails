# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bitbucket
    user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in user if user.persisted?
    redirect_to root_url
  end

  def passthru
    super
  end

  def failure
    super
  end

  # protected

  def after_omniauth_failure_path_for(scope)
    super(scope)
  end
end
