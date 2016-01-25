# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/provider_chef_dk_debian'

describe Chef::Provider::ChefDk::Debian do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Debian' do
      let(:platform) { { platform: 'debian', version: '7.6' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '#install!' do
    let(:package_source) { 'http://example.com/cdk.deb' }
    let(:package_checksum) { '12345' }

    before(:each) do
      %i(chef_gem remote_file dpkg_package).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      %i(package_source package_checksum).each do |m|
        allow_any_instance_of(described_class).to receive(m)
          .and_return(send(m))
      end
    end

    it 'downloads the package from the specified source' do
      p = provider
      expect(p).to receive(:remote_file).with(
        "#{Chef::Config[:file_cache_path]}/cdk.deb"
      ).and_yield
      expect(p).to receive(:source).with('http://example.com/cdk.deb')
      expect(p).to receive(:checksum).with('12345')
      p.send(:install!)
    end

    it 'installs the downloaded package' do
      p = provider
      expect(p).to receive(:dpkg_package).with(
        "#{Chef::Config[:file_cache_path]}/cdk.deb"
      )
      p.send(:install!)
    end
  end

  describe '#remove!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:dpkg_package)
    end

    it 'removes the Chef-DK package' do
      p = provider
      expect(p).to receive(:dpkg_package).with('chefdk').and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end
end
