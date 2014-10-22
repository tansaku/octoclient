require 'dotenv'
Dotenv.load
require 'octoclient/content'
require 'octoclient/team'
require 'json'


module OctoClient

  ASSETS = 'https://assets-cdn.github.com/images/icons/emoji/'
  ACCESS_PARAMS = "?access_token=#{ENV['GITHUB_ACCESS_TOKEN']}&client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
  API_URL = "https://api.github.com"
  ORGANIZATION = 'AgileVentures'
  COURSE_REPO = "#{ORGANIZATION}/module1"
  PRE_COURSE_REPO = "#{ORGANIZATION}/module0"

  # TODO would love to have admin editability for these the various constants

  def self.orgs_url(user_token)
    "#{API_URL}/user/orgs?access_token=#{user_token}"
  end

  def self.orgs(user_token)
    get orgs_url(user_token)
  end

  def self.blob_url(username, repo_name, blob_sha)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/blobs/#{blob_sha}#{ACCESS_PARAMS}"  
  end

  def self.blob(username, repo_name, blob_sha) 
    hash = get(blob_url(username, repo_name, blob_sha))
    begin
      hash['content']
    rescue NoMethodError => error
      puts "Failed to load: #{username}, #{repo_name} - #{error}"
      raise error
    end
  end

  def self.create_blob_url(username, repo_name)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/blobs#{ACCESS_PARAMS}"  
  end

  def self.create_blob(username, repo_name, content) 
    post_body = "{\"content\": \"#{content}\", \"encoding\": \"utf-8\"}"
    hash = post(create_blob_url(username, repo_name),post_body)
    begin
      hash['sha']
    rescue NoMethodError => error
      puts "Failed to load: #{username}, #{repo_name} - #{error}"
      raise error
    end
  end

  def self.create_tree_url(username, repo_name)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/trees#{ACCESS_PARAMS}"  
  end

  def self.create_tree(username, repo_name, path, content, base_tree_sha)
    post_body = %Q{
      {
        "base_tree":"#{base_tree_sha}",
        "tree": [
         {
           "path": "#{path}",
           "mode": "100644",
           "type": "blob",
           "content": "#{content}"
         }
       ]
      }
    }
    post(create_tree_url(username, repo_name),post_body)
  end

  def self.commit_url(username, repo_name, sha)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/commits/#{sha}#{ACCESS_PARAMS}"  
  end

  def self.commit(username, repo_name, sha)
    get commit_url(username, repo_name, sha)
  end

  def self.create_commit_url(username, repo_name)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/commits#{ACCESS_PARAMS}"  
  end


  def self.create_commit(username, repo_name, tree_sha, message, parent_commit_sha)
    post_body = %Q{
      {
        "message": "#{message}",
        "author": {
          "name": "Sam Joseph",
          "email": "tansaku@gmail.com"
        },
        "parents": ["#{parent_commit_sha}"],
        "tree": "#{tree_sha}"
      }
    }
    post(create_commit_url(username, repo_name),post_body)
  end

  def self.ref(username, repo_name, ref)
    get ref_url(username, repo_name, ref)
  end

  def self.ref_url(username, repo_name, ref)
    "#{API_URL}/repos/#{username}/#{repo_name}/git/refs/#{ref}#{ACCESS_PARAMS}"  
  end

  def self.update_ref(username, repo_name, ref, commit_sha)
    post_body =%Q{
      {
         "sha": "#{commit_sha}",
         "force": true
      }
    }
    post(ref_url(username, repo_name, ref),post_body)
  end

  def self.update_file(username, repo_name, path, content)
    repo_ref = ref(username, repo_name, 'heads/master')
    parent_commit_sha = repo_ref['object']['sha']
    existing_history = ContentAPI::content(username, repo_name, path)
    new_content = append_history(existing_history, content)
    commit = commit(username, repo_name, parent_commit_sha)
    tree = create_tree(username, repo_name, path, new_content, commit['tree']['sha']) 
    commit = create_commit(username, repo_name, tree['sha'], 'woohoo',parent_commit_sha)
    update_ref(username, repo_name, 'heads/master', commit['sha'])
  end

  def self.repos_url(username)
    "#{API_URL}/users/#{username}/repos#{ACCESS_PARAMS}"  
  end

  def self.repos(username)
    get(repos_url(username))
  end

  def self.repo_commits_url(username, repo_name)
    "#{API_URL}/repos/#{username}/#{repo_name}/commits#{ACCESS_PARAMS}"
  end

  def self.repo_commits(username, repo_name)
    get(repo_commits_url(username, repo_name))
  end

  def self.precourse_content_url(filename = '')
    filename = 'README.md' if filename.empty?
    "#{API_URL}/repos/#{PRE_COURSE_REPO}/contents/#{filename}#{ACCESS_PARAMS}"
  end

  def self.precourse_content path
    hash = get self.precourse_content_url path
    begin
      Base64.decode64 hash['content']
    rescue NoMethodError => error
      puts "Failed to load: #{path} - #{error}"
      raise error
    end
  end

  def self.append_history(response, content)
    existing_content = response.nil? ? '' : response
    "#{existing_content.gsub("\n", '')} #{content}"
  end

  def self.get url
    uri = URI(url)
    str = Net::HTTP.get(uri)
    JSON.parse(str)
  end

  # curl --data '{"name":"testrepo"}' -X POST -u username https://api.github.com/user/repos
  # curl https://api.github.com/repos/tansaku/api-test/git/blobs/5a81f646cb0e3fb6edc31e486946421709256b86
  # curl https://api.github.com/repos/tansaku/api-test/git/blobs/889c2f64a41d3ea261c2082c18480d9d1b12b72b
  # curl --data '{"content":"testrepo"}' https://api.github.com/repos/tansaku/api-test/git/blobs/5a81f646cb0e3fb6edc31e486946421709256b86

  def self.post url, post_body
    uri = URI(url)
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true if url =~ /^https/
    response = http.request_post(uri.request_uri, post_body)
    JSON.parse(response.read_body)
  end

  def self.put url, put_body
    uri = URI(url)
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true if url =~ /^https/
    response = http.request(Net::HTTP::Put.new(uri.request_uri, nil), put_body)
    begin
      JSON.parse(response.read_body)
    rescue TypeError
      nil
    end
  end
  
end