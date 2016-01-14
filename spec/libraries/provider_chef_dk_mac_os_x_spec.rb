# Encoding: UTF-8

require_relative '../spec_helper'
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

  describe '#tailor_package_resource_to_platform' do
    let(:filename) { 'chefdk-0.2.2-1.dmg' }
    let(:package) do
      double(app: true,
             volumes_dir: true,
             source: true,
             type: true,
             package_id: true)
    end
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end
    let(:res) { provider.send(:tailor_package_resource_to_platform) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:filename)
        .and_return(filename)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
    end

    it 'calls `app` with the new naming style' do
      expect(package).to receive(:app).with('chefdk-0.2.2-1')
      res
    end

    it 'calls `volumes_dir` with the new naming style' do
      expected = 'Chef Development Kit'
      expect(package).to receive(:volumes_dir).with(expected)
      res
    end

    it 'calls `source` with the local file path' do
      expect(package).to receive(:source).with('file:///tmp/blah.pkg')
      provider.send(:tailor_package_resource_to_platform)
    end

    it 'calls `type` with `pkg`' do
      expect(package).to receive(:type).with('pkg')
      provider.send(:tailor_package_resource_to_platform)
    end

    it 'calls `package_id` with `com.getchef.pkg.chefdk`' do
      expect(package).to receive(:package_id).with('com.getchef.pkg.chefdk')
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns the DmgPackage resource' do
      expected = Chef::Resource::DmgPackage
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#bashrc_file' do
    it 'returns "bashrc"' do
      expect(provider.send(:bashrc_file)).to eq('/etc/bashrc')
    end
  end
end
