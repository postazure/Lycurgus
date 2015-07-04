require 'rails_helper'

RSpec.describe SearchController, type: :controller do
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
      get :results, {"utf8"=>"✓", "repo_url"=>"https://github.com/postazure/Lycurgus", "commit"=>"Discover Licenses"}

      expect(WebMock).to have_requested(:get, 'https://api.github.com/repos/postazure/Lycurgus/git/trees/418d41e06005df5e22e35873da1a4baaaa017433').once
    end
  end
end
