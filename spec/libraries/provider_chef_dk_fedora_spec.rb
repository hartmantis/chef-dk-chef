# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk_fedora'

describe Chef::Provider::ChefDk::Fedora do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Fedora' do
      let(:platform) { { platform: 'fedora', version: '22' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'CentOS' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
  end

  describe '#package_provider_class' do
    it 'returns Chef::Provider::Package::Rpm' do
      expected = Chef::Provider::Package::Rpm
      expect(provider.send(:package_provider_class)).to eq(expected)
    end
  end

  describe '#bashrc_file' do
    it 'returns "bashrc"' do
      expect(provider.send(:bashrc_file)).to eq('/etc/bashrc')
    end
  end
end
