# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk_windows'

describe Chef::Provider::ChefDk::Windows do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
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
