# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk_amazon'

describe Chef::Provider::ChefDk::Amazon do
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
