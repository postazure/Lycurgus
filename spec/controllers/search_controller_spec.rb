require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  let(:params) {{"utf8"=>"✓", "repo_url"=>"https://github.com/postazure/Lycurgus", "commit"=>"Discover Licenses"}}

  describe '#results' do
    let(:commits_url) {'https://api.github.com/repos/postazure/Lycurgus/commits'}
    let(:commits_response) {IO.read('spec/fixtures/github/commit_history_search_response_success.txt')}
    let(:tree_url) {'https://api.github.com/repos/postazure/Lycurgus/git/trees/418d41e06005df5e22e35873da1a4baaaa017433'}
    let(:tree_response) {IO.read('spec/fixtures/github/tree_search_response_success.txt')}
    let(:gemfile_lock_url) {'https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock'}
    let(:gemfile_lock_response) {IO.read('spec/fixtures/github/gemfile_lock_short_response_success.txt')}
    let(:rubygems_url1) {'https://rubygems.org/api/v1/versions/byebug.json'}
    let(:rubygems_response1) {IO.read('spec/fixtures/rubygems/byebug_versions_response_success.txt')}
    let(:rubygems_url2) {'https://rubygems.org/api/v1/versions/coffee-rails.json'}
    let(:rubygems_response2) {IO.read('spec/fixtures/rubygems/coffee-rails_versions_response_success.txt')}

    before do
      stub_request(:get, commits_url).to_return(body: commits_response)
      stub_request(:get, tree_url).to_return(body: tree_response)
      stub_request(:get, gemfile_lock_url).to_return(body: gemfile_lock_response)
      stub_request(:get, rubygems_url1).to_return(body: rubygems_response1)
      stub_request(:get, rubygems_url2).to_return(body: rubygems_response2)
    end

    it 'it reads the sha' do
      get :results, params

      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/postazure/Lycurgus/git/trees/418d41e06005df5e22e35873da1a4baaaa017433').once
    end
  end

  describe '#commit_shas_gemfile_lock' do
    let(:shas) {[
        {
            'sha' => '5d2dabf51a7182daed652ac3c48f93dda7f3f01d',
            'date' => '2015-07-03T20:56:45Z',
            'message' => "Can get repo content using github api\\\n\\\n[finishes #98372026]",
            'url' => 'https://api.github.com/repos/postazure/Lycurgus/git/commits/5d2dabf51a7182daed652ac3c48f93dda7f3f01d'
        },
        {
            'sha' => '6f8fa9bb8cb2b88d8c502c2aff301296251eb11b',
            'date' => '2015-07-03T19:00:29Z',
            'message' => 'first commit',
            'url' => 'https://api.github.com/repos/postazure/Lycurgus/git/commits/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'
        }
    ]}

    let(:commits_with_file_url) {'https://api.github.com/repos/postazure/Lycurgus/commits?path=Gemfile.lock'}
    let(:commits_with_file_response) {IO.read('spec/fixtures/github/commits_with_gemfile_lock_response_success.txt')}
    before do
      stub_request(:get, commits_with_file_url).to_return({body: commits_with_file_response})
    end

    it 'returns an array of sha where Gemfile.lock was included' do
      get :commit_shas_gemfile_lock, params

      body = JSON.parse(response.body)
      expect(body.length).to eq 2
      expect(body).to eq shas
    end
  end
end
