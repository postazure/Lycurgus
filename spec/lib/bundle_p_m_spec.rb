require 'spec_helper'
require 'package_managers/bundler_p_m'

describe BundlerPM do
  let(:repo_info) {IO.read('spec/fixtures/github/tree_search_response_success.txt')}

  let(:bundler_pm) {BundlerPM.new(repo_info)}

  let(:tree_url) {'https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'}
  let(:gemfile_lock_url) {'https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock'}

  let(:serialized_gems) {[{
                              name: 'semantic-ui-sass',
                              version: '1.12.3.0',
                              sha: 'be4cb632ada01e484a0b17d1399c80cbafaa9a9f',
                              source: 'GIT'
                          },
                          {
                              name: 'twitter-bootstrap-rails',
                              version: '3.2.1',
                              sha: '935f53bb55ef736260fa2ef04e29da2fc3fb2b3f',
                              source: 'GIT'
                          },
                          {
                              name: 'actionmailer',
                              version: '4.2.2',
                              sha: nil,
                              source: 'GEM'
                          },
                          {
                              name: 'actionpack',
                              version: '4.2.2',
                              sha: nil,
                              source: 'GEM'
                          }]}
  let(:serialized_gems_with_licenses) {[{
                              name: 'semantic-ui-sass',
                              version: '1.12.3.0',
                              sha: 'be4cb632ada01e484a0b17d1399c80cbafaa9a9f',
                              source: 'GIT',
                              notices: [],
                              licenses: ['MIT']
                          },
                          {
                              name: 'twitter-bootstrap-rails',
                              version: '3.2.1',
                              sha: '935f53bb55ef736260fa2ef04e29da2fc3fb2b3f',
                              source: 'GIT',
                              notices: {version: 'No exact match for version, found license info for version 3.2.1.rc1.'},
                              licneses: ['MIT']

                          },
                          {
                              name: 'actionmailer',
                              version: '4.2.2',
                              sha: 'c8907839cf984bd9fd7f2c0096cb3801d528784e79a883d9fcfe9600a3a60356',
                              source: 'GEM',
                              notices: [],
                              licenses: ['MIT']
                          },
                          {
                              name: 'actionpack',
                              version: '4.2.2',
                              sha: '4809adcf25c2efba47d28872b35c2196974ececcb2fd88bf2f628729074df106',
                              source: 'GEM',
                              notices: {licenses: 'Gem has no license.'},
                              licenses: []
                          }]}

  describe '#get_file_url_at_sha' do
    it 'gets the content of the gemfile.lock' do
      expect(bundler_pm.send(:get_file_url_at_sha, {'url'=>tree_url})).to eq gemfile_lock_url
    end
  end

  describe '#serialize_gems' do
    let(:parsed_file) {eval IO.read('spec/fixtures/local/parse_gemfile_lock_complex_multi.txt')}
    it 'serializes gems' do
      gems = bundler_pm.send(:serialize_gems, parsed_file)
      serialized_gems.each do |gem_info|
        expect(gems).to include(gem_info)
      end
    end
  end

  describe '#compile_with_rubygems' do
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
    end

    it 'returns a hash with sha and licenses info' do
      gems = bundler_pm.send(:compile_with_rubygems!, serialized_gems)
      expect(gems.map {|g| g[:licenses]} ).to include(['MIT'], [])
      expect(gems.map {|g| g[:notices]}).to include(
        [{version: 'No exact match for version, found license info for version 3.2.1.rc1.'}],
        [{licenses: 'Gem has no license.'}],
        []
      )
    end
  end
end