describe OctoClient::TeamAPI do

  let(:post_hash){ {body: %Q{{"id":"123456"}}} }

  it '.create_team' do
    stub_request(:post, OctoClient::TeamAPI.org_teams_url('AgileVentures'))
      .with({body: %Q{{"name": "LocalSupport Team"}}})
      .to_return(post_hash)
    response = OctoClient::TeamAPI.create_team('AgileVentures', 'LocalSupport Team', nil,'pull')
    expect(response['id']).to eq '123456'
  end

  it '.add_team_member' do
    stub_request(:put, OctoClient::TeamAPI.team_member_url('1324354', 'tansaku'))
      .to_return({body: ''})
    response = OctoClient::TeamAPI.add_team_member('1324354', 'tansaku')
    expect(response).to eq nil
  end
end