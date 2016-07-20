# frozen_string_literal: true
require_relative '../resources'

shared_context 'resources::chef_dk_gem' do
  include_context 'resources'

  let(:resource) { 'chef_dk_gem' }
  let(:properties) { {} }
  let(:name) { 'testgem' }

  let(:runner) do
    ChefSpec::SoloRunner.new(
      platform: platform, version: platform_version
    ) do |node|
      %i(resource name action).each do |p|
        next if send(p).nil?
        node.default['chef_dk_resource_test'][p] = send(p)
      end
    end
  end

  let(:gem_path) { nil }

  shared_examples_for 'any platform' do
    context 'the default action (:install)' do
      it 'installs the gem with the correct path' do
        expect(chef_run).to install_chef_dk_gem('testgem')
          .with(gem_binary: File.expand_path(gem_path))
      end
    end

    context 'the :upgrade action' do
      let(:action) { :upgrade }

      it 'upgrade the gem with the correct path' do
        expect(chef_run).to upgrade_chef_dk_gem('testgem')
          .with(gem_binary: File.expand_path(gem_path))
      end
    end

    context 'the :remove action' do
      let(:action) { :remove }

      it 'removes the gem with the correct path' do
        expect(chef_run).to remove_chef_dk_gem('testgem')
          .with(gem_binary: File.expand_path(gem_path))
      end
    end
  end
end
