require 'httpx/adapters/faraday'
Faraday.default_adapter = :httpx

class BitbucketConnection
  def initialize(user)
    @connection = Faraday.new url: 'https://api.bitbucket.org' do |conn|
      conn.authorization :Bearer, user.access_token
      conn.request :url_encoded
    end

    @repositories_path = "2.0/repositories/#{Rails.application.credentials.bitbucket.workspace_name}"
  end

  def branches(repo_name)
    response = @connection.get("#{@repositories_path}/#{repo_name}/refs/branches")

    JSON.parse(response.body).to_h['values']
  end

  def repositories
    response = @connection.get(@repositories_path)

    JSON.parse(response.body).to_h['values'].map { |repo| repo['name'] }
  end

  def tag_info(repo_name)
    response = @connection.get("#{@repositories_path}/#{repo_name}/refs/tags")

    response = JSON.parse(response.body)
    
    response['values'].map do |tag|
      info = tagged_commit(repo_name, tag['name'])
      branch = info[:branch]
      commit = info[:hash]

      {
        name: tag['name'],
        branch: branch,
        commit: commit,
        tagger: tag['tagger']['user']['display_name'],
        date: DateTime.parse(tag['date']).strftime("%H:%M %m-%d-%Y")
      }
    end
  end

  def state
    repositories.map { |repo| { name: repo, environment_tags: tag_info(repo) } }
  end

  def tagged_commit(repo_name, tag)
    response = @connection.get("#{@repositories_path}/#{repo_name}/commits/#{tag}")
    response_body = JSON.parse(response.body)

    return nil if response_body['error']

    commit_hash = response_body['values'].first['hash']
    branch = branches(repo_name).select { |branch| branch['target']['hash'] == commit_hash }.first['name']

    return { hash: commit_hash, branch: branch }
  end
end