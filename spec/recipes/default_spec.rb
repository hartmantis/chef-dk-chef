# Encoding: UTF-8

require_relative '../spec_helper'

describe 'chef-dk::default' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  %i(version source global_shell_init).each { |a| let(a) { nil } }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(version source global_shell_init).each do |a|
        node.default['chef_dk'][a] = send(a) unless send(a).nil?
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'with default attributes' do
    it 'installs the latest version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk')
        .with(version: nil, source: :direct, global_shell_init: false)
    end
  end

  context 'an overridden `version` attribute' do
    let(:version) { '1.2.3-4' }

    it 'installs the specified version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: '1.2.3-4')
    end
  end

  context 'an overridden `source` attribute' do
    let(:source) { 'http://example.com/pkg.pkg' }

    it 'installs from the desired package URL' do
      expect(chef_run).to install_chef_dk('chef_dk')
        .with(source: 'http://example.com/pkg.pkg')
    end
  end
end
