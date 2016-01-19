# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
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

  describe '#install!' do
    let(:package_url) { nil }
    let(:new_resource) do
      r = super()
      r.package_url(package_url) unless package_url.nil?
      r
    end
    let(:metadata) do
      double(url: 'http://example.com/cdk.msi', sha256: '12345')
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
      %i(chef_gem windows_package).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'windows')
    end

    context 'no package source provided' do
      let(:package_url) { nil }

      it 'installs the package via metadata' do
        p = provider
        expect(p).to receive(:windows_package).with('Chef Development Kit')
          .and_yield
        expect(p).to receive(:source).with('http://example.com/cdk.msi')
        expect(p).to receive(:checksum).with('12345')
        p.send(:install!)
      end
    end

    context 'a remote package source provided' do
      let(:package_url) { 'http://example.com/other.msi' }

      it 'installs the package via the source' do
        p = provider
        expect(p).to receive(:windows_package).with('Chef Development Kit')
          .and_yield
        expect(p).to receive(:source).with('http://example.com/other.msi')
        expect(p).to_not receive(:checksum)
        p.send(:install!)
      end
    end

    context 'a local package source provided' do
      let(:package_url) { '/tmp/chefdk.msi' }

      it 'installs the package via the source' do
        p = provider
        expect(p).to receive(:windows_package).with('Chef Development Kit')
          .and_yield
        expect(p).to receive(:source).with('/tmp/chefdk.msi')
        expect(p).to_not receive(:checksum)
        p.send(:install!)
      end
    end
  end

  describe '#remove!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'windows')
    end

    it 'removes the ChefDK package' do
      p = provider
      expect(p).to receive(:windows_package).with('Chef Development Kit')
        .and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end

  describe '#bashrc_file' do
    it 'raises an exception' do
      expected = Chef::Exceptions::UnsupportedPlatform
      expect { provider.send(:bashrc_file) }.to raise_error(expected)
    end
  end
end
