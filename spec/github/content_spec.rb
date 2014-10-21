describe Github::ContentAPI do
  let(:content){ Base64.strict_encode64 'hello'}
  let(:hash){ {body: %Q{{"content":"#{content}", "sha":"456"}}} }
  let(:no_content_hash){ {body: %Q{{}}} }
  let(:post_hash){ {body: %Q{{"commit":{"sha":"456"}}}} }

  it '.content' do
    stub_request(:get, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(hash)
    response = Github::ContentAPI.content('tansaku', 'api-test', 'README.md')
    expect(response).to eq 'hello'
  end

  it '.content <-- should fail gracefully' do
    stub_request(:get, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(no_content_hash)
    response = Github::ContentAPI.content('tansaku', 'api-test', 'README.md')
    expect(response).to eq ''
  end

  it '.update_content' do
    stub_request(:put, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(post_hash)
    response = Github::ContentAPI.update_content('tansaku','api-test', 'README.md','woot!', 'test', '123')
    expect(response['commit']['sha']).to eq '456'
  end

  it '.create_content' do
    stub_request(:put, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(post_hash)
    response = Github::ContentAPI.create_content('tansaku','api-test', 'README.md','woot!', 'test')
    expect(response['commit']['sha']).to eq '456'
  end
  
  it '.append_content with no existing content' do
    stub_request(:get, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(no_content_hash)
    body = %Q{{
           "message": "woot!",
           "content": "#{Base64.strict_encode64 'test'}"
      }}
    stub_request(:put, Github::ContentAPI.content_url('tansaku', 'api-test')).with({body:body}).to_return(post_hash)
    response = Github::ContentAPI.append_content('tansaku','api-test', 'README.md','woot!', 'test')
    expect(response['commit']['sha']).to eq '456'
  end

  it '.append_content with existing content' do
    stub_request(:get, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(hash)
    stub_request(:put, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(post_hash)
    response = Github::ContentAPI.append_content('tansaku','api-test', 'README.md','woot!', 'test')
    expect(response['commit']['sha']).to eq '456'
  end

  it '.append_content with existing content only if not already present' do
    stub_request(:get, Github::ContentAPI.content_url('tansaku', 'api-test')).to_return(hash)
    response = Github::ContentAPI.append_content('tansaku','api-test', 'README.md','woot!', 'hello')
    expect(response).to be nil
  end

end