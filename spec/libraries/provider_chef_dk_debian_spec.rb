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
    let(:package_url) { nil }
    let(:new_resource) do
      r = super()
      r.package_url(package_url) unless package_url.nil?
      r
    end
    let(:metadata) do
      double(url: 'http://example.com/cdk.deb', sha256: '12345')
    end

    before(:each) do
      %i(chef_gem remote_file dpkg_package).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(double(write_file: true))
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'ubuntu')
    end

    context 'no package source provided' do
      let(:package_url) { nil }

      it 'downloads the package from the metadata source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/cdk.deb"
        ).and_yield
        expect(p).to receive(:source).with('http://example.com/cdk.deb')
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

    context 'a remote package source provided' do
      let(:package_url) { 'http://example.com/other.deb' }

      it 'downloads the package via the source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/other.deb"
        ).and_yield
        expect(p).to receive(:source).with('http://example.com/other.deb')
        p.send(:install!)
      end

      it 'installs the downloaded package' do
        p = provider
        expect(p).to receive(:dpkg_package).with(
          "#{Chef::Config[:file_cache_path]}/other.deb"
        )
        p.send(:install!)
      end
    end

    context 'a local package source provided' do
      let(:package_url) { '/tmp/chefdk.deb' }

      it 'copies the package via the source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/chefdk.deb"
        ).and_yield
        expect(p).to receive(:source).with('/tmp/chefdk.deb')
        p.send(:install!)
      end

      it 'installs the downloaded package' do
        p = provider
        expect(p).to receive(:dpkg_package).with(
          "#{Chef::Config[:file_cache_path]}/chefdk.deb"
        )
        p.send(:install!)
      end
    end
  end

  describe '#remove!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:package)
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(double(write_file: true))
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'ubuntu')
    end

    it 'removes the Chef-DK package' do
      p = provider
      expect(p).to receive(:package).with('chefdk').and_yield
      expect(p).to receive(:action).with(:remove)
      p.send(:remove!)
    end
  end

  describe '#bashrc_file' do
    it 'returns "bash.bashrc"' do
      expect(provider.send(:bashrc_file)).to eq('/etc/bash.bashrc')
    end
  end
end
