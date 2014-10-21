require 'spec_helper'
require 'webmock/rspec'

describe Github do

  let(:content){ Base64.strict_encode64 'hello'}
  let(:current_path){'/some_content_path'}

  context 'precourse content' do
    before(:each){stub_precourse_content}

    it '.grab --> retrieves hash from Github api' do
      response = Github.get Github.precourse_content_url
      expect(response).to be_a Hash
      expect(response['content']).to eq content
    end

    it '.precourse_content --> retrieves and decodes Github content' do
      response = Github.precourse_content 'README.md'
      expect(response).to eq 'hello'
    end
  end

  it '.blob --> retrieves and decodes Github blob' do
    args = ['tansaku', 'api-test','5a81f646cb0e3fb6edc31e486946421709256b86']
    stub_blob_with args
    expect(Github.blob(*args)).to eq 'hello'
  end

  it '.create_blob --> creates Github blob returning sha' do
    stub_create_blob
    response = Github.create_blob('tansaku', 'api-test', 'hello')
    expect(response).to eq '123'
  end

  
  it '.ref' do
    stub_ref_url
    response = Github.ref('tansaku','api-test','heads/master')
    expect(response['ref']).to eq 'heads/master'
  end

  it '.commit' do
    stub_commit
    response = Github.commit('tansaku','api-test','123')
    expect(response['tree']['sha']).to eq '456'
  end

  context 'involving trees' do

    before do
      stub_create_tree
    end

    let(:tree){Github.create_tree('tansaku', 'api-test', 'README.md', 'hello', '123')}

    it '.create_tree' do
      expect(tree['tree']['sha']).to eq '123'
    end

    context 'involving commits' do

      before do
        stub_create_commit
      end

      let(:commit){Github.create_commit('tansaku', 'api-test', tree['sha'], 'woot!', '123')}

      it '.create_commit' do
        expect(commit['sha']).to eq '123'
      end

      context 'involving refs/branches' do
        
        before do
          stub_ref
        end

        let(:ref){Github.update_ref('tansaku', 'api-test', 'heads/master', commit['sha'] )}

        it '.update_ref' do
          expect(ref['ref']).to eq 'heads/master'
        end

        it '.update_file' do
          stub_update_file
          Github.update_file('tansaku', 'api-test', 'README.md', 'hello')
        end

        it '.append_history --> adds current path to visited pages' do
          response = "/visited_path"
          expect(Github.append_history(response, current_path)).to eq "/visited_path #{current_path}"
        end
      end
    end
  end
end