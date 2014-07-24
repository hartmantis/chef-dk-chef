# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider/chef_dk
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
    let(:new_resource) { double(:'installed=' => true) }
    let(:remote_file) { double(run_action: true) }
    let(:package) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:new_resource)
        .and_return(new_resource)
      allow_any_instance_of(described_class).to receive(:remote_file)
        .and_return(remote_file)
      allow_any_instance_of(described_class).to receive(:package)
        .and_return(package)
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
  end

  describe '#action_uninstall' do
    let(:new_resource) { double(:'installed=' => true) }
    let(:remote_file) { double(run_action: true) }
    let(:package) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:new_resource)
        .and_return(new_resource)
      allow_any_instance_of(described_class).to receive(:remote_file)
        .and_return(remote_file)
      allow_any_instance_of(described_class).to receive(:package)
        .and_return(package)
    end

    it 'downloads the package remote file' do
      expect(remote_file).to receive(:run_action).with(:delete)
      provider.action_uninstall
    end

    it 'installs the package file' do
      expect(package).to receive(:run_action).with(:uninstall)
      provider.action_uninstall
    end

    it 'sets the installed state to false' do
      expect(new_resource).to receive(:'installed=').with(false)
      provider.action_uninstall
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

  describe '#platform' do
    [
      {
        platform: 'ubuntu',
        version: '12.04'
      },
      {
        platform: 'windows',
        version: '2012'
      }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it 'returns the platform name' do
          expect(provider.send(:platform)).to eq(p[:platform])
        end
      end
    end
  end

  describe '#platform_version' do
    [
      {
        platform: 'ubuntu',
        version: '12.04',
        expected: '12.04'
      },
      {
        platform: 'windows',
        version: '2012',
        expected: '6.2.9200'
      }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }

        it 'returns the platform version' do
          expect(provider.send(:platform_version)).to eq(p[:expected])
        end
      end
    end
  end

  describe '#version' do
    let(:version) { nil }
    let(:new_resource) { double(version: version) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:new_resource)
        .and_return(new_resource)
    end

    context 'a version specified with the resource' do
      let(:version) { '6.6.6' }

      it 'returns the specified version' do
        expect(provider.send(:version)).to eq('6.6.6')
      end
    end

    context 'no version provided with the resource' do
      it 'returns the default latest version' do
        expect(provider.send(:version)).to eq('0.2.0-2')
      end
    end
  end

  describe '#remote_file' do
    let(:remote_file) { double(source: true) }

    before(:each) do
      allow(Chef::Resource::RemoteFile).to receive(:new).and_return(remote_file)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/package.pkg')
      allow_any_instance_of(described_class).to receive(:package_url)
        .and_return('http://package.com/package.pkg')
    end

    it 'returns an instance of Chef::Resource::RemoteFile' do
      res = provider.send(:remote_file)
      expect(res).to be_an_instance_of(RSpec::Mocks::Double)
    end
  end

  describe '#package_url' do
    let(:platform) { { platform: 'ubuntu', version: '12.04' } }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:new_resource)
        .and_return(new_resource)
      allow_any_instance_of(described_class).to receive(:platform)
        .and_return('ubuntu')
      allow_any_instance_of(described_class).to receive(:platform_version)
        .and_return('12.04')
      allow_any_instance_of(described_class).to receive(:package_file)
        .and_return('chefdk_0.2.0-2_amd64.deb')
    end

    context 'with no custom URL provided' do
      it 'pieces together the correct URL' do
        expected = 'https://opscode-omnibus-packages.s3.amazonaws.com' \
                   '/ubuntu/12.04/x86_64/chefdk_0.2.0-2_amd64.deb'
        expect(provider.send(:package_url)).to eq(expected)
      end
    end

    context 'with a custom URL provided' do
      let(:package_url) { 'http://example.com/package.pkg' }

      it 'returns the custom URL' do
        expect(provider.send(:package_url)).to eq(package_url)
      end
    end
  end

  describe '#download_path' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:package_file)
        .and_return('test.deb')
    end

    it 'returns a path in the Chef file_cache_path' do
      expect(provider.send(:download_path)).to eq('/var/chef/cache/test.deb')
    end
  end

  describe '#package_file' do
    let(:package_file_elements) { nil }
    let(:package_file_separator) { nil }
    let(:package_file_extension) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:package_file_elements)
        .and_return(package_file_elements)
      allow_any_instance_of(described_class).to receive(:package_file_separator)
        .and_return(package_file_separator)
      allow_any_instance_of(described_class).to receive(:package_file_extension)
        .and_return(package_file_extension)
    end

    [
      {
        platform: 'ubuntu',
        version: '12.04',
        elements: %w(chefdk 0.2.0-2 amd64),
        separator: '_',
        extension: '.deb',
        expected: 'chefdk_0.2.0-2_amd64.deb'
      },
      {
        platform: 'centos',
        version: '6.0',
        elements: %w(chefdk 0.2.0 2.el6.x86_64),
        separator: '-',
        extension: '.rpm',
        expected: 'chefdk-0.2.0-2.el6.x86_64.rpm'
      },
      {
        platform: 'mac_os_x',
        version: '10.9.2',
        elements: %w(chefdk 0.2.0 2),
        separator: '-',
        extension: '.dmg',
        expected: 'chefdk-0.2.0-2.dmg'
      },
      {
        platform: 'windows',
        version: '2012',
        elements: %w(chefdk windows 0.2.0 2.windows),
        separator: '-',
        extension: '.msi',
        expected: 'chefdk-windows-0.2.0-2.windows.msi'
      }
    ].each do |p|
      context "a #{p[:platform]}-#{p[:version]} node" do
        let(:platform) { { platform: p[:platform], version: p[:version] } }
        let(:package_file_elements) { p[:elements] }
        let(:package_file_separator) { p[:separator] }
        let(:package_file_extension) { p[:extension] }

        it 'returns the correct package file name' do
          expect(provider.send(:package_file)).to eq(p[:expected])
        end
      end
    end
  end

  describe '#package_file_elements' do
    it 'returns the package name and version by default' do
      expect(provider.send(:package_file_elements)).to eq(%w(chefdk 0.2.0-2))
    end
  end

  describe '#package_file_separator' do
    it 'returns a hyphen' do
      expect(provider.send(:package_file_separator)).to eq('-')
    end
  end

  describe '#package_file_extension' do
    it 'raises an error' do
      expect { provider.send(:package_file_extension) }.to raise_error(
        Chef::Provider::ChefDk::NotImplemented
      )
    end
  end
end
