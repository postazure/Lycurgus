require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  let(:params) {{"utf8"=>"✓", "repo_url"=>"https://github.com/postazure/Lycurgus", "commit"=>"Discover Licenses"}}

  describe '#results' do
    let(:commits_url) {"https://api.github.com/repos/postazure/Lycurgus/commits?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"}
    let(:commits_response) {IO.read('spec/fixtures/github/commit_history_search_response_success.txt')}
    let(:tree_url) {"https://api.github.com/repos/postazure/Lycurgus/git/trees/418d41e06005df5e22e35873da1a4baaaa017433?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"}
    let(:tree_response) {IO.read('spec/fixtures/github/tree_search_response_success.txt')}
    let(:gemfile_lock_url) {'https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock'}
    let(:gemfile_lock_response) {IO.read('spec/fixtures/github/gemfile_lock_complex_multi_response_success.txt')}
    let(:rubygems_url1) {'https://rubygems.org/api/v1/versions/byebug.json'}
    let(:rubygems_response1) {IO.read('spec/fixtures/rubygems/byebug_versions_response_success.txt')}
    let(:rubygems_url2) {'https://rubygems.org/api/v1/versions/coffee-rails.json'}
    let(:rubygems_response2) {IO.read('spec/fixtures/rubygems/coffee-rails_versions_response_success.txt')}

    let(:ordered_requests) {[
        'https://rubygems.org/api/v1/versions/semantic-ui-sass.json',
        'https://rubygems.org/api/v1/versions/twitter-bootstrap-rails.json',
        'https://rubygems.org/api/v1/versions/actionmailer.json',
        'https://rubygems.org/api/v1/versions/actionpack.json'
    ]}
    let(:ordered_responses) {[
        IO.read('spec/fixtures/rubygems/semantic-ui-sass_versions_response_success.txt'),
        IO.read('spec/fixtures/rubygems/twitter-bootstrap-rails_versions_response_success.txt'),
        IO.read('spec/fixtures/rubygems/actionmailer_versions_response_success.txt'),
        IO.read('spec/fixtures/rubygems/actionpack_versions_response_success.txt')
    ]}

    before do
      ordered_requests.each_with_index do |request, i|
        stub_request(:get, request).to_return({body: ordered_responses[i]})
      end

      stub_request(:get, commits_url).to_return(body: commits_response)
      stub_request(:get, tree_url).to_return(body: tree_response)
      stub_request(:get, gemfile_lock_url).to_return(body: gemfile_lock_response)
      stub_request(:get, rubygems_url1).to_return(body: rubygems_response1)
      stub_request(:get, rubygems_url2).to_return(body: rubygems_response2)
    end

    it 'it reads the sha' do
      get :results, params

      expect(WebMock).to have_requested(
         :get,
         "https://api.github.com/repos/postazure/Lycurgus/git/trees/418d41e06005df5e22e35873da1a4baaaa017433?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
       ).once
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

    let(:commits_with_file_url) {"https://api.github.com/repos/postazure/Lycurgus/commits?path=Gemfile.lock&client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"}
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

  describe '#license_defs' do
    let(:open_source_licenses_response) { IO.read('spec/fixtures/osi/licenses_response.txt') }
    let(:osi_url) { 'opensource.org/licenses/alphabetical' }

    before do
      stub_request(:get, osi_url).to_return({body: open_source_licenses_response})
    end

    it 'gets licenses from open source licenses' do
      get :license_defs

      body = JSON.parse(response.body)
      expect( body.map{|l| l['name']}   ).to include('Academic Free License 3.0', 'Mozilla Public License 2.0', 'Zope Public License 2.0')
      expect( body.map{|l| l['short']}  ).to include('MIT', 'Apache-2.0', 'W3C')
      expect( body.map{|l| l['url']}    ).to include('http://opensource.org/licenses/APSL-2.0', 'http://opensource.org/licenses/OGTSL', 'http://opensource.org/licenses/Sleepycat')
    end
  end
end
