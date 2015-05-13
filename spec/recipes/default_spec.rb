# Encoding: UTF-8

require_relative '../spec_helper'

describe 'chef-dk::default' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      overrides.each do |k, v|
        node.set['chef_dk'][k] = v
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'with default attributes' do
    it 'installs the latest version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: 'latest')
    end
  end

  context 'an overridden `version` attribute' do
    let(:overrides) { { version: '1.2.3-4' } }

    it 'installs the specified version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: '1.2.3-4')
    end
  end

  context 'an overridden `package_url` attribute' do
    let(:overrides) { { package_url: 'http://example.com/pkg.pkg' } }

    it 'installs from the desired package URL' do
      expect(chef_run).to install_chef_dk('chef_dk')
        .with(package_url: 'http://example.com/pkg.pkg')
    end
  end

  context 'overridden `version` and `package_url` attributes' do
    let(:overrides) do
      { version: '1.2.3-4', package_url: 'http://example.com/pkg.pkg' }
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_exception(Chef::Exceptions::ValidationFailed)
    end
  end
end
