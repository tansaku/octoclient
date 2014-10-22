module OctoClient
  class ContentAPI

    # TODO REFACTOR LIKE SO
    # def initialize(username, repo_name)
    #   @username = username
    #   @repo_name = repo_name
    # end

    def self.content_url username, repo_name, path = '' 
      path = 'README.md' if path.empty?
      "#{API_URL}/repos/#{username}/#{repo_name}/contents/#{path}#{ACCESS_PARAMS}"
    end

    def self.content username, repo_name, path 
      hash = get_content username, repo_name, path 
      begin
        Base64.decode64 hash['content']
      rescue NoMethodError => error
        puts "Failed to load: #{path} - #{error}"
        return ''
      end
    end

    def self.get_content username, repo_name, path 
      OctoClient::get self.content_url username, repo_name, path 
    end

    def self.update_content username, repo_name, path, commit_message, content, sha, branch = 'master'
      put_body = %Q{{
           "message": "#{commit_message}",
           "content": "#{Base64.strict_encode64 content}",
           "sha": "#{sha}"
      }}
      OctoClient::put(content_url(username, repo_name, path), put_body)  
    end

    def self.create_content username, repo_name, path, commit_message, content, branch = 'master' 
      put_body = %Q{{
           "message": "#{commit_message}",
           "content": "#{Base64.strict_encode64 content}"
      }}
      OctoClient::put(content_url(username, repo_name, path), put_body)  
    end

    def self.append_content username, repo_name, path, commit_message, append, branch = 'master'
      begin
        existing = get_content username, repo_name, path 
        return if Base64.decode64(existing['content']).include? append
        content = Base64.decode64(existing['content']) + append
        response = update_content username, repo_name, path, commit_message, content, existing['sha'], branch 
      rescue StandardError => error # TODO not quite happy about this - would like to get more specific
        puts "Failed to load: #{path} - #{error}"
        response = create_content username, repo_name, path, commit_message, append, branch
      end
    end
  end
end