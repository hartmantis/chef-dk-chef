# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk_windows'

describe Chef::Provider::ChefDk::Windows do
  let(:platform) { {} }
  let(:chefdk_version) { nil }
  let(:package_url) { nil }
  let(:new_resource) do
    double(name: 'my_chef_dk',
           version: chefdk_version,
           package_url: package_url)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(
      Fauxhai.mock(platform).data
    )
    stub_const('::File::ALT_SEPARATOR', '\\')
  end

  describe '#tailor_package_resource_to_platform' do
    let(:package) { double(source: true) }
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.msi')
    end

    it 'calls `source` with the local file path' do
      expect(package).to receive(:source).with('/tmp/blah.msi')
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns Chef::Resource::WindowsPackage' do
      expected = Chef::Resource::WindowsPackage
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#bashrc_file' do
    it 'raises an exception' do
      expected = Chef::Exceptions::UnsupportedPlatform
      expect { provider.send(:bashrc_file) }.to raise_error(expected)
    end
  end
end
