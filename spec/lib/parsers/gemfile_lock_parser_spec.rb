require 'spec_helper'
require 'parsers/gemfile_lock_parser'

describe GemfileLockParser do
  let(:multi_complex_return) {eval IO.read('spec/fixtures/local/parse_gemfile_lock_complex_multi.txt')}
  let(:gemfile_lock_content) {IO.read('spec/fixtures/github/gemfile_lock_complex_multi_response_success.txt')}

  it '#deps' do
    parser = GemfileLockParser.new(gemfile_lock_content)
    expect(parser.parse).to eq multi_complex_return
  end
end
