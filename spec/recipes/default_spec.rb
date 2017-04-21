# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::default' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  %i[version channel source checksum gems shell_users].each do |a|
    let(a) { nil }
  end
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i[version channel source checksum gems shell_users].each do |a|
        node.normal['chef_dk'][a] = send(a) unless send(a).nil?
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
      expect(chef_run).to create_chef_dk('default').with(version: '1.2.3-4')
    end
  end

  context 'an overridden `channel` attribute' do
    let(:channel) { :current }

    it 'installs from the desired channel' do
      expect(chef_run).to create_chef_dk('default').with(channel: :current)
    end
  end

  context 'an overridden `source` attribute' do
    let(:source) { :repo }

    it 'installs from the desired package URL' do
      expect(chef_run).to create_chef_dk('default').with(source: :repo)
    end
  end

  context 'an overridden `checksum` attribute' do
    let(:checksum) { 'abc123' }

    it 'installs with the configured checksum' do
      expect(chef_run).to create_chef_dk('default').with(checksum: 'abc123')
    end
  end

  context 'an overridden `gems` attribute' do
    let(:gems) { %w[test1 test2] }

    it 'installs the desired Chef-DK gems' do
      expect(chef_run).to create_chef_dk('default').with(gems: %w[test1 test2])
    end
  end

  context 'an overridden `shell_users` attribute' do
    let(:shell_users) { %w[me them] }

    it 'configures the desired users shells' do
      expect(chef_run).to create_chef_dk('default')
        .with(shell_users: %w[me them])
    end
  end
end
