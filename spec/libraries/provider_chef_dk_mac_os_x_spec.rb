# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/provider_chef_dk_mac_os_x'

describe Chef::Provider::ChefDk::MacOsX do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

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
    let(:package_source) { nil }
    let(:package_checksum) { nil }

    before(:each) do
      %i(chef_gem dmg_package).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      %i(package_source package_checksum).each do |m|
        allow_any_instance_of(described_class).to receive(m)
          .and_return(send(m))
      end
    end

    context 'a remote package source provided' do
      let(:package_source) { 'http://example.com/other.dmg' }
      let(:package_checksum) { '12345' }

      it 'installs the package via the source' do
        p = provider
        expect(p).to receive(:dmg_package).with('Chef Development Kit')
          .and_yield
        expect(p).to receive(:app).with('other')
        expect(p).to receive(:volumes_dir).with('Chef Development Kit')
        expect(p).to receive(:source).with('http://example.com/other.dmg')
        expect(p).to receive(:type).with('pkg')
        expect(p).to receive(:package_id).with('com.getchef.pkg.chefdk')
        expect(p).to receive(:checksum).with('12345')
        p.send(:install!)
      end
    end

    context 'a local package source provided' do
      let(:package_source) { '/tmp/chefdk.dmg' }
      let(:package_checksum) { nil }

      it 'installs the package via the source' do
        p = provider
        expect(p).to receive(:dmg_package).with('Chef Development Kit')
          .and_yield
        expect(p).to receive(:app).with('chefdk')
        expect(p).to receive(:volumes_dir).with('Chef Development Kit')
        expect(p).to receive(:source).with('file:///tmp/chefdk.dmg')
        expect(p).to receive(:type).with('pkg')
        expect(p).to receive(:package_id).with('com.getchef.pkg.chefdk')
        expect(p).to receive(:checksum).with(nil)
        p.send(:install!)
      end
    end
  end

  describe '#remove!' do
    before(:each) do
      %i(directory execute).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      allow_any_instance_of(described_class).to receive(:node)
        .and_return('platform' => 'mac_os_x')
    end

    it 'deletes the application and additional dirs' do
      p = provider
      ['/opt/chefdk', File.expand_path('~/.chefdk')].each do |d|
        expect(p).to receive(:directory).with(d).and_yield
        expect(p).to receive(:recursive).with(true)
        expect(p).to receive(:action).with(:delete)
      end
      p.send(:remove!)
    end

    it 'forgets the package from pkgutil' do
      p = provider
      expect(p).to receive(:execute)
        .with('pkgutil --forget com.getchef.pkg.chefdk').and_yield
      expect(p).to receive(:only_if)
        .with('pkgutil --pkg-info com.getchef.pkg.chefdk')
      p.send(:remove!)
    end
  end

  describe '#bashrc_file' do
    it 'returns "bashrc"' do
      expect(provider.send(:bashrc_file)).to eq('/etc/bashrc')
    end
  end
end
