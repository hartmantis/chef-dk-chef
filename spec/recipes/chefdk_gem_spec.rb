# Encoding: UTF-8

require_relative '../spec_helper'

describe 'chef-dk::chefdk_gem' do
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
    it 'installs the latest version of knife-supermarket to chefdk gemset' do
      expect(chef_run).to install_chef_dk_gem('knife-supermarket').with(
        user: 'root'
      )
    end
  end
end
