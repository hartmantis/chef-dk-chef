# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider_chef_dk
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk'

describe Chef::Provider::ChefDk do
  let(:base_url) { 'https://opscode-omnibus-packages.s3.amazonaws.com' }
  let(:platform) { {} }
  [
    :version, :prerelease, :nightlies, :package_url, :global_shell_init
  ].each { |i| let(i) { nil } }
  let(:node) { Fauxhai.mock(platform).data }
  let(:new_resource) do
    double(name: 'my_chef_dk',
           cookbook_name: 'chef-dk',
           version: version,
           prerelease: prerelease,
           nightlies: nightlies,
           package_url: package_url,
           global_shell_init: global_shell_init,
           :installed= => true)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(node)
  end

  describe '#whyrun_supported?' do
    it 'supports whyrun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    it 'returns a ChefDk resource' do
      expected = Chef::Resource::ChefDk
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_install' do
    [:omnijack_gem, :remote_file, :package].each do |i|
      let(i) { double(run_action: true) }
    end
    let(:gsi) { double(write_file: true) }
    let(:yolo) { false }
    let(:metadata) { double(yolo: yolo) }

    before(:each) do
      [:omnijack_gem, :remote_file, :package, :metadata].each do |r|
        allow_any_instance_of(described_class).to receive(r)
          .and_return(send(r))
      end
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(gsi)
    end

    it 'installs the omnijack gem' do
      expect(omnijack_gem).to receive(:run_action).with(:install)
      provider.action_install
    end

    it 'downloads the package remote file' do
      expect(remote_file).to receive(:run_action).with(:create)
      provider.action_install
    end

    it 'installs the package file' do
      expect(package).to receive(:run_action).with(:install)
      provider.action_install
    end

    it 'sets the installed state to true' do
      expect(new_resource).to receive(:'installed=').with(true)
      provider.action_install
    end

    it 'does not modify any bashrc' do
      expect(gsi).not_to receive(:write_file)
      provider.action_install
    end

    context 'overridden global shell init' do
      let(:global_shell_init) { true }

      it 'modifies bashrc' do
        expect_any_instance_of(described_class).to receive(:global_shell_init)
          .with(:create)
        expect(gsi).to receive(:write_file)
        provider.action_install
      end
    end

    context 'a "yolo" package' do
      let(:yolo) { true }

      it 'logs a warning to Chef' do
        expect(Chef::Log).to receive(:warn).with('Using a ChefDk package ' \
                                                 'not officially supported ' \
                                                 'on this platform')
        provider.action_install
      end
    end
  end

  describe '#action_remove' do
    let(:remote_file) { double(run_action: true) }
    let(:package) { double(run_action: true) }
    let(:gsi) { double(write_file: true) }

    before(:each) do
      [:remote_file, :package].each do |r|
        allow_any_instance_of(described_class).to receive(r)
          .and_return(send(r))
      end
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(gsi)
    end

    it 'does not modify any bashrc' do
      expect(gsi).not_to receive(:write_file)
      provider.action_remove
    end

    context 'overridden global shell init' do
      let(:global_shell_init) { true }

      it 'modifies bashrc' do
        expect_any_instance_of(described_class).to receive(:global_shell_init)
          .with(:delete)
        expect(gsi).to receive(:write_file)
        provider.action_remove
      end
    end

    it 'deletes the package remote file' do
      expect(remote_file).to receive(:run_action).with(:delete)
      provider.action_remove
    end

    it 'installs the package file' do
      expect(package).to receive(:run_action).with(:remove)
      provider.action_remove
    end

    it 'sets the installed state to false' do
      expect(new_resource).to receive(:'installed=').with(false)
      provider.action_remove
    end
  end

  describe '#package' do
    let(:package_resource_class) { Chef::Resource::Package }
    let(:package_provider_class) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(
        :package_resource_class).and_return(package_resource_class)
      allow_any_instance_of(described_class).to receive(
        :package_provider_class).and_return(package_provider_class)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
      allow_any_instance_of(described_class).to receive(
        :tailor_package_resource_to_platform).and_return(true)
    end

    shared_examples_for 'any node' do
      it 'returns a package resource' do
        expected = package_resource_class
        expect(provider.send(:package)).to be_an_instance_of(expected)
      end
    end

    context 'all default' do
      it_behaves_like 'any node'

      it 'does not call a custom provider' do
        expect_any_instance_of(package_resource_class).to_not receive(:provider)
        provider.send(:package)
      end
    end

    context 'with custom resource and provider classes given' do
      let(:package_resource_class) { Chef::Resource::DmgPackage }
      let(:package_provider_class) { Chef::Provider::DmgPackage }

      it_behaves_like 'any node'

      it 'calls the custom provider' do
        expect_any_instance_of(package_resource_class).to receive(:provider)
          .with(package_provider_class)
        provider.send(:package)
      end
    end
  end

  describe '#tailor_package_resource_to_platform' do
    let(:package) { double(version: true) }
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end
    let(:version) { '6.6.6' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:version)
        .and_return(version)
    end

    it 'does a version call on the package resource' do
      expect(package).to receive(:version).with(version)
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns Chef::Resource::Package' do
      expected = Chef::Resource::Package
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#package_provider_class' do
    it 'returns nil' do
      expect(provider.send(:package_provider_class)).to eq(nil)
    end
  end

  describe '#global_shell_init' do
    before(:each) do
      @fakebashrc = Tempfile.new('chefdkspec')
      allow_any_instance_of(described_class).to receive(:bashrc_file)
        .and_return(@fakebashrc.path)
    end

    after(:each) do
      @fakebashrc.delete
    end

    it 'returns a FileEdit object' do
      expected = Chef::Util::FileEdit
      expect(provider.send(:global_shell_init)).to be_an_instance_of(expected)
    end
  end

  describe '#remote_file' do
    let(:metadata) { double(url: 'http://x.com/pack.pkg', sha256: 'lolnope') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/pack.pkg')
    end

    it 'returns an instance of Chef::Resource::RemoteFile' do
      expected = Chef::Resource::RemoteFile
      expect(provider.send(:remote_file)).to be_an_instance_of(expected)
    end
  end

  describe '#download_path' do
    let(:metadata) { double(filename: 'test.deb') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
    end

    it 'returns a path in the Chef file_cache_path' do
      expected = File.join(Chef::Config[:file_cache_path], 'test.deb')
      expect(provider.send(:download_path)).to eq(expected)
    end
  end

  describe '#metadata' do
    it 'returns a Metadata instance' do
      require 'omnijack'
      expect_any_instance_of(Omnijack::Project::ChefDk).to receive(:metadata)
        .and_return('A METADATA OBJECT')
      expect(provider.send(:metadata)).to eq('A METADATA OBJECT')
    end
  end

  describe '#omnijack_gem' do
    it 'returns a ChefGem instance' do
      expected = Chef::Resource::ChefGem
      expect(provider.send(:omnijack_gem)).to be_an_instance_of(expected)
    end
  end

  describe '#bashrc_file' do
    it 'raises an error' do
      expect { provider.send(:bashrc_file) }.to raise_error(
        Chef::Provider::ChefDk::NotImplemented
      )
    end
  end
end
