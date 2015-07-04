require 'spec_helper'
require 'repo'
require 'json'

describe Repo do
  let(:tree_response) {JSON.parse(IO.read('spec/fixtures/github/tree_search_response_success.txt'))}
  let(:repo) {Repo.new(tree_response)}

  describe '#intitialize' do

    it 'creates a repo object' do
      expect(repo.name).to eq 'Lycurgus'
      expect(repo.owner).to eq 'postazure'
      expect(repo.url).to eq 'github.com/postazure/Lycurgus'
      expect(repo.sha).to eq '6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'
    end
  end

  describe 'determine active package manager' do
    it 'returns Bundler is active' do
      expect(repo.send(:active_pms)).to include(BundlerPM)
    end
  end

  describe 'Get Gem Info from Gemfile.lock' do
    let(:commit_url) {'https://api.github.com/repos/postazure/Lycurgus/commits/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'}
    let(:gemfile_lock_url) {'https://github.com/postazure/Lycurgus/raw/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b/Gemfile.lock'}
    let(:commit_response) {IO.read('spec/fixtures/github/commit_search_response_success.txt')}
    let(:gemfile_lock_response) {IO.read('spec/fixtures/github/gemfile_lock_response_success.txt')}

    before do
      stub_request(:get, commit_url).to_return(body: commit_response)
      stub_request(:get, gemfile_lock_url).to_return(body: gemfile_lock_response)
    end

    describe '#get_gemlock_at_sha' do
      it 'gets the content of the gemfile.lock' do
        expect(repo.send(:get_file_url_at_sha, 'Gemfile.lock')).to eq gemfile_lock_url
      end
    end

    describe '#current_packages' do
      let(:packages) {eval IO.read('spec/fixtures/local/bundler_p_m_current_packages_return.txt')}

      before do
        allow(repo).to receive(:active_pms) {[BundlerPM]}
        allow_any_instance_of(BundlerPM).to receive(:current_packages) {packages}
      end

      it 'returns package objects' do
        current_packages = repo.current_packages

        expect(current_packages.count).to eq 12
        expect(current_packages.map(&:name)).to include(
            'byebug',
            'coffee-rails',
            'jbuilder',
            'jquery-rails',
            'pg'
        )
      end
    end
  end
end

# https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock
# 'https://api.github.com/repos/postazure/Lycurgus/commits/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'