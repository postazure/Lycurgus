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
end
