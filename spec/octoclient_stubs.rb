module OctoClientStubs

  SHA_HASH = {body: "{\"sha\":\"123\"}"}
  HELLO_HASH = {body: "{\"content\":\"hello\"}"}
  REF_HASH = {body: "{\"ref\":\"heads/master\", \"object\":{\"sha\":\"123\"}}"}
  TREE_HASH = {body: "{ \"tree\": {\"sha\":\"123\"}}"}

  def stub_update_file
    stub_request(:get, OctoClient.ref_url('tansaku','api-test', 'heads/master'))
            .to_return(REF_HASH)
    stub_request(:get, OctoClient.commit_url('tansaku', 'api-test', '123'))
            .to_return(TREE_HASH)
  end

  def stub_ref
    stub_request(:post, OctoClient.ref_url('tansaku', 'api-test', 'heads/master'))
            .to_return(REF_HASH)
    stub_request(:get, OctoClient::ContentAPI.content_url('tansaku', 'api-test', 'README.md')).to_return(HELLO_HASH)
  end

  def stub_ref_url
    stub_request(:get, OctoClient.ref_url('tansaku', 'api-test', 'heads/master'))
            .to_return(REF_HASH)
  end

  def stub_commit
    stub_request(:get, OctoClient.commit_url('tansaku', 'api-test', '123'))
      .to_return({body: "{\"tree\":{\"sha\":\"456\"}}"})
  end

  def stub_create_tree
    stub_request(:post, OctoClient.create_tree_url('tansaku', 'api-test'))
          .to_return(TREE_HASH)
  end

  def stub_create_commit
    stub_request(:post, OctoClient.create_commit_url('tansaku', 'api-test'))
            .to_return(SHA_HASH)
  end

  def stub_create_blob
    stub_request(:post, OctoClient.create_blob_url('tansaku', 'api-test')).
         with(:body => "{\"content\": \"hello\", \"encoding\": \"utf-8\"}")
          .to_return(SHA_HASH)
  end

  def stub_blob_with args
    stub_request(:get, OctoClient.blob_url(*args)).to_return({body: "{\"content\":\"hello\"}"})
  end

  def stub_precourse_content
    stub_request(:get, OctoClient.precourse_content_url).to_return({body: "{\"content\":\"#{content}\", \"sha\":\"456\"}"})
  end

  def stub_repo_and_return commits
      stub_repos('tansaku')
      stub_request(:get, OctoClient.repo_commits_url('tansaku', 'playing-with-git')).to_return(body: commits)
  end

  def stub_repos username
      stub_request(:get, OctoClient.repos_url(username)).to_return(body: '[{"name":"playing-with-git"}, {"name":"octocat_test"}]')
  end

  def stub_content_requests
    stub_request(:get, OctoClient.orgs_url(@user.token)).to_return(body: '[{"id": 3636186}]')
    stub_precourse_content
    stub_request(:get, OctoClient::ContentAPI.content_url('tansaku', 'api-test', 'danldb')).to_return(hash)
    stub_request(:put, OctoClient::ContentAPI.content_url('tansaku', 'api-test', 'danldb')).to_return(post_hash)
  end

  def stub_progress_and_tracker username, repo_name, commits, content
    stub_request(:get, OctoClient.repos_url(username)).to_return(body: %Q{[{"name":"#{repo_name}"}]})
    PreCourse.instance.tasks.each do |tasks|
      stub_request(:get, OctoClient.repo_commits_url(username,tasks.default_repo)).to_return(body: commits)
    end
    stub_tracker_with username, content
  end

  def stub_tracker_with login, content
    code = Base64.strict_encode64 content
    hash = {body: %Q{{"content":"#{code}", "sha":"456"}}}
    stub_request(:get, OctoClient::ContentAPI.content_url('tansaku', 'api-test', login)).to_return(hash)
  end

  def stub_content_and_tracking
    stub_precourse_content
    stub_request(:get, OctoClient::ContentAPI.content_url('tansaku', 'api-test', 'tansaku')).to_return(hash)
    stub_request(:put, OctoClient::ContentAPI.content_url('tansaku', 'api-test', 'tansaku')).to_return(post_hash)
  end

  def stub_user_in_approved_org
    stub_request(:get, OctoClient.orgs_url(@user.token)).to_return(body: '[{"id": 3636186}]')
  end

  def stub_user_not_in_approved_org
    stub_request(:get, OctoClient.orgs_url(@user.token)).to_return(body: '[{"id": 123}]')
  end

end