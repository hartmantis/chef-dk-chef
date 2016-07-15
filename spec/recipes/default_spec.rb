# Encoding: UTF-8

require_relative '../spec_helper'

describe 'chef-dk::default' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  %i(version source gems shell_users).each { |a| let(a) { nil } }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(version source gems shell_users).each do |a|
        node.default['chef_dk'][a] = send(a) unless send(a).nil?
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'with default attributes' do
    it 'installs the latest version of the Chef-DK' do
      expect(chef_run).to create_chef_dk('default')
        .with(gems: [], shell_users: [])
    end
  end

  context 'an overridden `version` attribute' do
    let(:version) { '1.2.3-4' }

    it 'installs the specified version of the Chef-DK' do
      pending
      expect(chef_run).to create_chef_dk('default').with(version: '1.2.3-4')
    end
  end

  context 'an overridden `source` attribute' do
    let(:source) { 'http://example.com/pkg.pkg' }

    it 'installs from the desired package URL' do
      pending
      expect(chef_run).to create_chef_dk('chef_dk')
        .with(source: 'http://example.com/pkg.pkg')
    end
  end

  context 'an overridden `gems` attribute' do
    let(:gems) { %w(test1 test2) }

    it 'installs the desired Chef-DK gems' do
      expect(chef_run).to create_chef_dk('default').with(gems: %w(test1 test2))
    end
  end

  context 'an overridden `shell_users` attribute' do
    let(:shell_users) { %w(me them) }

    it 'configures the desired users shells' do
      expect(chef_run).to create_chef_dk('default')
        .with(shell_users: %w(me them))
    end
  end
end
