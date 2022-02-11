require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class BitbucketConnection
  def initialize user
    @connection = Faraday.new url: 'https://api.bitbucket.org' do |conn|
      conn.authorization :Bearer, user.access_token
      conn.request :url_encoded
    end
  end

  def repository repo_name
    response = @connection.get(
      "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}"
    )
    JSON.parse(response.body)
  end

  def repositories
    response = @connection.get(
      "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}"
      )
    JSON.parse(response.body)
  end

  def branches repo_name
    response = @connection.get(
      "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/refs/branches"
    )
    # JSON.parse(response.body).to_h['values'].map { |branch| branch['name'] }
    JSON.parse(response.body)
  end

  def tagged_commit(repo_name, tag)
    commits_response = @bitbucket_connection.get(
      "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/commits/#{tag}"
    )

    tagged_commit_hash = JSON.parse(commits_response.body)

    # tagged_commit_hash = tagged ? tagged.to_h['values'].first['hash'] : nil

    # response = @bitbucket_connection.get(
    #   "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}/#{repo_name}/refs/branches"
    # )

    # name = JSON.parse(response.body).to_h['values'].select { |branch| branch['target']['hash'] == tagged_commit_hash }.first['name']
  end

  def environment_tags(repo_name)
    production_tag = tagged_commit(repo_name, 'production')
    stagev2_tag = tagged_commit(repo_name, 'stagev2')
    upgrade_tag = tagged_commit(repo_name, 'upgrade')

    { production: production_tag, stagev2: stagev2_tag, upgrade: upgrade_tag }
  end
end