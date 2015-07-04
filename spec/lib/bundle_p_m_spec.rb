require 'spec_helper'
require 'package_managers/bundler_p_m'

describe BundlerPM do
  let(:repo_info) {IO.read('spec/fixtures/github/tree_search_response_success.txt')}
  let(:gemfile_lock_info) {IO.read('spec/fixtures/github/gemfile_lock_response_success.txt')}

  let(:bundler_pm) {BundlerPM.new(repo_info)}

  let(:tree_url) {'https://api.github.com/repos/postazure/Lycurgus/git/trees/6f8fa9bb8cb2b88d8c502c2aff301296251eb11b'}
  let(:gemfile_lock_url) {'https://raw.githubusercontent.com/postazure/Lycurgus/master/Gemfile.lock'}

  describe '#get_file_url_at_sha' do
    it 'gets the content of the gemfile.lock' do
      allow_any_instance_of(BundlerPM).to receive(:initialize)
      expect(bundler_pm.send(:get_file_url_at_sha, {'url'=>tree_url})).to eq gemfile_lock_url
    end
  end

  describe 'parse Gemfile.lock' do
    before do
      allow(ApiClient).to receive(:process_response) {gemfile_lock_info}
    end

    describe '#parse_dependencies_chunk' do
      it 'returns only gems (top level deps)' do
        gem_names = bundler_pm.send(:parse_dependencies_chunk)

        expect(gem_names).to include('byebug', 'pg', 'web-console')
        expect(gem_names.count).to eq 12
        expect(gem_names).not_to include('railties', 'rack', 'actionview')
      end
    end

    describe '#parse_spec_chunck' do
      it 'returns all deps and their versions' do
        deps = bundler_pm.send(:parse_spec_chunk)

        expect(deps.length).to eq 53
        expect(deps).to include(
          ['actionmailer', '4.2.2'],
          ['actionview', '4.2.2'],
        )
        expect(deps).not_to include(
          ['PLATFORMS'],
          ['specs:'],
        )
      end
    end
  end

  describe '#get_gem_info' do
    let(:dep_array) {[['byebug', '5.0.0']]}
    let(:gem_names_array) {['byebug']}
    let(:versions_response) {IO.read('spec/fixtures/rubygems/versions_response_success.txt')}

    before do
      stub_request(:get, 'https://rubygems.org/api/v1/versions/byebug.json')
          .to_return({body: versions_response})

      allow_any_instance_of(BundlerPM).to receive(:initialize)
      allow(bundler_pm).to receive(:parse_dependencies_chunk) {gem_names_array}
      allow(bundler_pm).to receive(:parse_spec_chunk) {dep_array}
    end

    it 'returns versions for gems' do
      gem_info_list = bundler_pm.send(:get_gem_info)

      # noinspection RubyResolve
      expect(gem_info_list).to include({
            name: 'byebug',
            version: '5.0.0',
            sha: '1e8966fc8e68eb321358ecc9b3b4799c3ee4e00844df3d5962d81c38407f987c',
            licenses: ['BSD'],
            source: 'https://rubygems.org/api/v1/versions/byebug.json'
      })
      expect(gem_info_list.count).to eq 1
    end
  end

  describe '#current_packages' do
    let(:gem_details) {eval IO.read('spec/fixtures/local/get_gem_info_return.txt')}

    before do
      allow_any_instance_of(BundlerPM).to receive(:initialize)
      allow(bundler_pm).to receive(:get_gem_info) {gem_details}
    end

    it 'returns an array of package objects' do
      current_packages = bundler_pm.current_packages

      expect(current_packages.count).to eq 2
      expect(current_packages[0].name).to eq 'byebug'
      expect(current_packages[0].sha).to eq '1e8966fc8e68eb321358ecc9b3b4799c3ee4e00844df3d5962d81c38407f987c'
      expect(current_packages[0].version).to eq '5.0.0'
      expect(current_packages[0].licenses).to eq ['BSD']
      expect(current_packages[1].name).to eq 'apple'
      expect(current_packages[1].sha).to eq '1e89dsrc8e68eb321358ecc9b3b4799c3ee4e00844df3d5962d81c38407f987c'
      expect(current_packages[1].version).to eq '1.0.0'
      expect(current_packages[1].licenses).to eq ['MIT']
    end
  end

  describe '#include_additional_info' do
    let(:versions_response) {IO.read('spec/fixtures/rubygems/versions_response_success.txt')}
    before do
      stub_request(:get, 'https://rubygems.org/api/v1/versions/byebug.json')
        .to_return({body: versions_response})
      allow_any_instance_of(BundlerPM).to receive(:initialize)
    end
    it 'returns a hash with sha and licenses info' do
      add_details = bundler_pm.send(:include_additional_info, ['byebug', '5.0.0'] )
      expect(add_details).to eq({
                                    name: 'byebug',
                                    version: '5.0.0',
                                    sha: '1e8966fc8e68eb321358ecc9b3b4799c3ee4e00844df3d5962d81c38407f987c',
                                    licenses: ['BSD'],
                                    source: 'https://rubygems.org/api/v1/versions/byebug.json'
                                })
    end
  end
end