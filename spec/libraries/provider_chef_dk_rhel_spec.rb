# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/provider_chef_dk_rhel'

describe Chef::Provider::ChefDk::Rhel do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Red Hat' do
      let(:platform) { { platform: 'redhat', version: '7.0' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'CentOS' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'Fedora' do
      let(:platform) { { platform: 'fedora', version: '22' } }

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
      double(url: 'http://example.com/cdk.rpm', sha256: '12345')
    end

    before(:each) do
      %i(chef_gem remote_file rpm_package).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'redhat')
    end

    context 'no package source provided' do
      let(:package_url) { nil }

      it 'downloads the package from the metadata source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/cdk.rpm"
        ).and_yield
        expect(p).to receive(:source).with('http://example.com/cdk.rpm')
        expect(p).to receive(:checksum).with('12345')
        p.send(:install!)
      end

      it 'installs the downloaded package' do
        p = provider
        expect(p).to receive(:rpm_package).with(
          "#{Chef::Config[:file_cache_path]}/cdk.rpm"
        )
        p.send(:install!)
      end
    end

    context 'a remote package source provided' do
      let(:package_url) { 'http://example.com/other.rpm' }

      it 'downloads the package via the source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/other.rpm"
        ).and_yield
        expect(p).to receive(:source).with('http://example.com/other.rpm')
        expect(p).to_not receive(:checksum)
        p.send(:install!)
      end

      it 'installs the downloaded package' do
        p = provider
        expect(p).to receive(:rpm_package).with(
          "#{Chef::Config[:file_cache_path]}/other.rpm"
        )
        p.send(:install!)
      end
    end

    context 'a local package source provided' do
      let(:package_url) { '/tmp/chefdk.rpm' }

      it 'copies the package via the source' do
        p = provider
        expect(p).to receive(:remote_file).with(
          "#{Chef::Config[:file_cache_path]}/chefdk.rpm"
        ).and_yield
        expect(p).to receive(:source).with('/tmp/chefdk.rpm')
        expect(p).to_not receive(:checksum)
        p.send(:install!)
      end

      it 'installs the downloaded package' do
        p = provider
        expect(p).to receive(:rpm_package).with(
          "#{Chef::Config[:file_cache_path]}/chefdk.rpm"
        )
        p.send(:install!)
      end
    end
  end

  describe '#remove!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:package)
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'redhat')
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
      expect(provider.send(:bashrc_file)).to eq('/etc/bashrc')
    end
  end
end
