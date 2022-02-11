# 0511c33c40b51c2a3c57b3adc3ca4e7eff5acea7
class HomeController < ApplicationController
  before_action :authenticate_user!, :refresh_token_if_expired!, :connect_to_bitbucket

  def index
    @data = @bitbucket.branches('test-roh-repo')
  end

  private

  def refresh_token_if_expired!
    return unless current_user.token_expiration_time.past?

    current_user.refresh_token!
  end

  def connect_to_bitbucket
    @bitbucket = BitbucketConnection.new current_user
  end
end
