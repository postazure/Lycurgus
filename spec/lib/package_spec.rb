require 'spec_helper'
require 'packages/package'

describe Package do
  let(:package) {Package.new(
    name: 'my-gem',
    version: '1.0.0'
  )}

  describe '#initialize' do
    it 'creates a package' do
      expect(package.name).to eq 'my-gem'
      expect(package.version).to eq '1.0.0'
    end
  end
end