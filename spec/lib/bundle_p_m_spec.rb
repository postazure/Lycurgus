require 'spec_helper'
require 'package_managers/bundler_p_m'

describe BundlerPM do
  let(:gemfile_lock_content) {IO.read('spec/fixtures/github/gemfile_lock_response_success.txt')}
  let(:bundler_pm) {BundlerPM.new(gemfile_lock_content)}

  describe 'parse Gemfile.lock' do
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

    describe '#get_gem_info' do
      let(:dep_array) {eval IO.read('spec/fixtures/local/parse_spec_chunk_return.txt')}
      let(:gem_names_array) {eval IO.read('spec/fixtures/local/parse_dependencies_chunk_return.txt')}

      it 'returns versions for gems' do
        allow(bundler_pm).to receive(:parse_dependencies_chunk) {gem_names_array}
        allow(bundler_pm).to receive(:parse_spec_chunk) {dep_array}

        gem_info_list = bundler_pm.send(:get_gem_info)

        expect(gem_info_list).to include(['byebug', '5.0.0'])
        expect(gem_info_list.count).to eq 12
      end
    end

    describe '#current_packages' do
      let(:gem_details) {eval IO.read('spec/fixtures/local/get_gem_info_return.txt')}

      before do
        allow(bundler_pm).to receive(:get_gem_info) {gem_details}
      end

      it 'returns an array of package objects' do
        current_packages = bundler_pm.current_packages

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