require 'spec_helper'
require 'repo'
require 'json'

describe Repo do
  describe 'Get Gem Info from Gemfile.lock' do
    let(:tree_url) {'https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'}
    let(:tree_response) {JSON.parse(IO.read('spec/fixtures/github/tree_search_response_success.txt'))}

    let(:gemfile_lock_url) {'https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock'}
    let(:gemfile_lock_content) {IO.read('spec/fixtures/github/gemfile_lock_short_response_success.txt')}

    let(:rubygems_url1) {'https://rubygems.org/api/v1/versions/byebug.json'}
    let(:rubygems_response1) {IO.read('spec/fixtures/rubygems/byebug_versions_response_success.txt')}
    let(:rubygems_url2) {'https://rubygems.org/api/v1/versions/coffee-rails.json'}
    let(:rubygems_response2) {IO.read('spec/fixtures/rubygems/coffee-rails_versions_response_success.txt')}

    let(:repo) {Repo.new(tree_response)}
    before do
      stub_request(:get, gemfile_lock_url).to_return(body: gemfile_lock_content)
      stub_request(:get, rubygems_url1).to_return(body: rubygems_response1)
      stub_request(:get, rubygems_url2).to_return(body: rubygems_response2)
    end

    it 'returns package objects' do
      current_packages = repo.current_packages

      expect(current_packages.count).to eq 2

      expect(current_packages[0].name).to eq 'byebug'
      expect(current_packages[0].sha).to eq '1e8966fc8e68eb321358ecc9b3b4799c3ee4e00844df3d5962d81c38407f987c'
      expect(current_packages[0].version).to eq '5.0.0'
      expect(current_packages[0].licenses).to eq ['BSD']

      expect(current_packages[1].name).to eq 'coffee-rails'
      expect(current_packages[1].sha).to eq '1adbc3d1e3e4d835643e7848b3279a7a1deadd8711be6a41bac1eb4788867f5c'
      expect(current_packages[1].version).to eq '4.1.0'
      expect(current_packages[1].licenses).to eq ['MIT']
    end
  end
end