require 'spec_helper'
require 'api_client'

describe ApiClient do
  describe '#github' do
    context 'plain text response' do
      let(:url) {"https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"}
      let(:txt_response) {IO.read('spec/fixtures/github/gemfile_lock_response_success.txt')}
      before do
        stub_request(:get, url).to_return({body: txt_response})
      end

      it 'makes a request and returns plain text' do
        res = ApiClient.process_response(url: url, json: false)
        expect(WebMock).to have_requested(:get, url).once
        expect(res.class).to be String
      end
    end

    context 'json response' do
      let(:url) {"https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"}
      let(:json_response) {IO.read('spec/fixtures/github/commit_search_response_success.txt')}
      before do
        stub_request(:get, url).to_return({body: json_response})
      end

      it 'makes a request and returns json' do
        res = ApiClient.process_response(url: url)
        expect(WebMock).to have_requested(:get, url).once
        expect(res.class).to be Hash
      end
    end
  end
end
