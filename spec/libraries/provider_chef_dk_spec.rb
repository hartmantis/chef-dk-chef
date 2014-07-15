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
  let(:provider) { Chef::Provider::ChefDk.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(Chef::Provider::ChefDk).to receive(:node).and_return(
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
      expect(provider.load_current_resource.class).to eq(Chef::Resource::ChefDk)
    end
  end

  describe '#action_install' do
    let(:new_resource) { double(:'installed=' => true) }
    let(:remote_file) { double(run_action: true) }
    let(:package) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:new_resource)
        .and_return(new_resource)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:remote_file)
        .and_return(remote_file)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:package)
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
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:new_resource)
        .and_return(new_resource)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:remote_file)
        .and_return(remote_file)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:package)
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
    let(:package_resource_class) { nil }
    let(:package_provider_class) { nil }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(
        :package_resource_class).and_return(package_resource_class)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(
        :package_provider_class).and_return(package_provider_class)
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(
        :tailor_package_resource_to_platform).and_return(true)
    end

    context 'a Mac OS X node' do
      let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }
      let(:package_resource_class) { Chef::Resource::DmgPackage }
      let(:package_provider_class) { Chef::Provider::Package }

      it 'returns a package resource' do
        expect(provider.send(:package).class).to eq(package_resource_class)
      end
    end

    context 'any other node' do
      let(:package_resource_class) { Chef::Resource::Package }
      let(:package_provider_class) { Chef::Provider::Package }

      it 'returns a package resource' do
        expect(provider.send(:package).class).to eq(package_resource_class)
      end
    end
  end

  describe '#tailor_package_resource_to_platform' do
    let(:package_resource) { nil }
    let(:pkg) { package_resource.new('chefdk') }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:pkg)
        .and_return(pkg)
    end

    context 'a Mac OS X node' do
      let(:package_resource) { Chef::Resource::DmgPackage }
      let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }

      it 'has the app name set' do
        expect_any_instance_of(package_resource).to receive(:app).with('chefdk')
        provider.send(:tailor_package_resource_to_platform, pkg)
      end

      it 'has the file URI set' do
        expect_any_instance_of(package_resource).to receive(:source)
          .with('file:///tmp/blah.pkg')
        provider.send(:tailor_package_resource_to_platform, pkg)
      end

      it 'has the pkg type set' do
        expect_any_instance_of(package_resource).to receive(:type)
          .with('pkg')
        provider.send(:tailor_package_resource_to_platform, pkg)
      end

      it 'does not receive a version' do
        expect_any_instance_of(package_resource).to_not receive(:version)
        provider.send(:tailor_package_resource_to_platform, pkg)
      end
    end

    context 'any other node' do
      let(:package_resource) { Chef::Resource::Package }

      it 'has the version set' do
        expect_any_instance_of(package_resource).to receive(:version)
        provider.send(:tailor_package_resource_to_platform, pkg)
      end
    end
  end

  describe '#package_resource_class' do
    {
      'ubuntu' => { '12.04' => 'Chef::Resource::Package' },
      'redhat' => { '6.5' => 'Chef::Resource::Package' },
      'centos' => { '6.5' => 'Chef::Resource::Package' },
      'mac_os_x' => { '10.9.2' => 'Chef::Resource::DmgPackage' }
    }.each do |os, attrs|
      attrs.each do |version, pkg_resource|
        context "a #{os} node" do
          let(:platform) { { platform: os, version: version } }

          it "returns the #{pkg_resource} class" do
            expected = pkg_resource.split('::').reduce(Object) do |mod, clss|
              mod.const_get(clss)
            end
            expect(provider.send(:package_resource_class)).to eq(expected)
          end
        end
      end
    end
  end

  describe '#package_provider_class' do
    {
      'ubuntu' => { '12.04' => 'Chef::Provider::Package::Dpkg' },
      'redhat' => { '6.5' => 'Chef::Provider::Package::Rpm' },
      'centos' => { '6.5' => 'Chef::Provider::Package::Rpm' },
      'mac_os_x' => { '10.9.2' => 'Chef::Provider::DmgPackage' }
    }.each do |os, attrs|
      attrs.each do |version, pkg_provider|
        context "a #{os} node" do
          let(:platform) { { platform: os, version: version } }

          it "returns the #{pkg_provider} class" do
            expected = pkg_provider.split('::').reduce(Object) do |mod, clss|
              mod.const_get(clss)
            end
            expect(provider.send(:package_provider_class)).to eq(expected)
          end
        end
      end
    end
  end

  describe '#version' do
    let(:version) { nil }
    let(:new_resource) { double(version: version) }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:new_resource)
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
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:download_path)
        .and_return('/tmp/package.pkg')
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:package_url)
        .and_return('http://package.com/package.pkg')
    end

    it 'returns an instance of Chef::Resource::RemoteFile' do
      res = provider.send(:remote_file)
      expect(res.class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#package_url' do
    let(:chefdk_version) { '0.2.0-2' }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:new_resource)
        .and_return(new_resource)
    end

    {
      'ubuntu' => { '12.04' => 'https://opscode-omnibus-packages.s3.' \
                               'amazonaws.com/ubuntu/12.04/x86_64/' \
                               'chefdk_0.2.0-2_amd64.deb',
                    '13.10' => 'https://opscode-omnibus-packages.s3.' \
                               'amazonaws.com/ubuntu/13.10/x86_64/' \
                               'chefdk_0.2.0-2_amd64.deb' },
      'redhat' => { '6.0' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.2.0-2.el6.x86_64.rpm',
                    '6.5' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.2.0-2.el6.x86_64.rpm' },
      'centos' => { '6.0' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.2.0-2.el6.x86_64.rpm',
                    '6.5' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.2.0-2.el6.x86_64.rpm' },
      'mac_os_x' => { '10.9.2' => 'https://opscode-omnibus-packages.s3.' \
                                  'amazonaws.com/mac_os_x/10.9/x86_64/' \
                                  'chefdk-0.2.0-2.dmg' }
    }.each do |os, versions|
      versions.each do |version, url|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          context 'no package_url override provided' do
            it 'returns the correct full package URL' do
              expect(provider.send(:package_url)).to eq(url)
            end
          end

          context 'a package_url provided' do
            let(:package_url) { 'http://example.com/package/url.package' }

            it 'returns the overridden package URL' do
              expect(provider.send(:package_url)).to eq(package_url)
            end
          end
        end
      end
    end
  end

  describe '#platform' do
    {
      'ubuntu' => { '12.04' => 'ubuntu', '13.10' => 'ubuntu' },
      'redhat' => { '6.0' => 'el', '6.5' => 'el' },
      'centos' => { '6.0' => 'el', '6.5' => 'el' },
      'mac_os_x' => { '10.9.2' => 'mac_os_x' }
    }.each do |os, versions|
      versions.each do |version, parsed_platform|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          it 'returns the correct platform version string' do
            expect(provider.send(:platform)).to eq(parsed_platform)
          end
        end
      end
    end
  end

  describe '#platform_version' do
    {
      'ubuntu' => { '12.04' => '12.04', '13.10' => '13.10' },
      'redhat' => { '6.0' => '6', '6.5' => '6' },
      'centos' => { '6.0' => '6', '6.5' => '6' },
      'mac_os_x' => { '10.9.2' => '10.9' }
    }.each do |os, versions|
      versions.each do |version, parsed_version|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          it 'returns the correct platform version for the package filename' do
            expect(provider.send(:platform_version)).to eq(parsed_version)
          end
        end
      end
    end
  end

  describe '#download_path' do
    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:package_file)
        .and_return('test.deb')
    end

    it 'returns a path in the Chef file_cache_path' do
      expect(provider.send(:download_path)).to eq('/var/chef/cache/test.deb')
    end
  end

  describe '#package_file' do
    let(:chefdk_version) { '0.2.0-2' }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:version)
        .and_return('0.2.0-2')
      allow_any_instance_of(Chef::Provider::ChefDk).to receive(:build)
        .and_return('1')
    end

    {
      'ubuntu' => { '12.04' => 'chefdk_0.2.0-2_amd64.deb',
                    '13.10' => 'chefdk_0.2.0-2_amd64.deb' },
      'redhat' => { '6.0' => 'chefdk-0.2.0-2.el6.x86_64.rpm',
                    '6.5' => 'chefdk-0.2.0-2.el6.x86_64.rpm' },
      'centos' => { '6.0' => 'chefdk-0.2.0-2.el6.x86_64.rpm',
                    '6.5' => 'chefdk-0.2.0-2.el6.x86_64.rpm' },
      'mac_os_x' => { '10.9.2' => 'chefdk-0.2.0-2.dmg' }
    }.each do |os, versions|
      versions.each do |version, filename|
        context "a #{os}-#{version} node" do
          before(:each) do
            allow_any_instance_of(Chef::Provider::ChefDk).to receive(:extension)
              .and_return(filename.split('.')[-1])
          end
          let(:platform) { { platform: os, version: version } }

          it 'returns the correct package filename' do
            expect(provider.send(:package_file)).to eq(filename)
          end
        end
      end
    end
  end

  describe '#package_file_separator' do
    {
      'ubuntu' => { '12.04' => '_', '13.10' => '_' },
      'redhat' => { '6.0' => '-', '6.5' => '-' },
      'centos' => { '6.0' => '-', '6.5' => '-' },
      'mac_os_x' => { '10.9.2' => '-' }
    }.each do |os, versions|
      versions.each do |version, separator|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          it "uses #{separator} as the filename separator" do
            expect(provider.send(:package_file_separator)).to eq(separator)
          end
        end
      end
    end
  end

  describe '#package_file_extension' do
    {
      'ubuntu' => { '12.04' => '.deb', '13.10' => '.deb' },
      'redhat' => { '6.0' => '.rpm', '6.5' => '.rpm' },
      'centos' => { '6.0' => '.rpm', '6.5' => '.rpm' },
      'mac_os_x' => { '10.9.2' => '.dmg' }
    }.each do |os, versions|
      versions.each do |version, extension|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          it "returns the #{extension} file extension" do
            expect(provider.send(:package_file_extension)).to eq(extension)
          end
        end
      end
    end
  end
end
