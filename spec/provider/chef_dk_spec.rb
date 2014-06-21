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
require_relative '../../libraries/provider/chef_dk'

describe Chef::Provider::ChefDK do
  let(:base_url) { 'https://opscode-omnibus-packages.s3.amazonaws.com' }
  let(:platform) { {} }
  let(:chefdk_version) { nil }
  let(:new_resource) { double(version: chefdk_version) }
  let(:provider) { Chef::Provider::ChefDK.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(Chef::Provider::ChefDK).to receive(:node).and_return(
      Fauxhai.mock(platform).data
    )
  end

  describe '#whyrun_supported?' do
    it 'supports whyrun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    it 'loads the correct version of an already-installed Chef-DK' do
      pending('Not yet')
    end
  end

  describe '#installed?' do
    let(:package) { double(version: double(nil?: false)) }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:package)
        .and_return(package)
    end

    it 'returns true if a version of the package is installed' do
      expect(provider.send(:installed?)).to eq(true)
    end
  end

  describe '#installed_version' do
    let(:package) { double(version: '6.6.6') }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:package)
        .and_return(package)
    end

    it 'returns the version string of the installed package' do
      expect(provider.send(:installed_version)).to eq('6.6.6')
    end
  end

  describe '#package' do
    let(:package) { double }

    before(:each) do
      allow(Chef::Resource::Package).to receive(:new).and_return(package)
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(
        :local_package_path).and_return('/tmp/package.pkg')
    end

    it 'returns an instance of Chef::Resource::Package' do
      expect(provider.send(:package).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#remote_file' do
    let(:remote_file) { double(source: true) }

    before(:each) do
      allow(Chef::Resource::RemoteFile).to receive(:new).and_return(remote_file)
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(
        :local_package_path).and_return('/tmp/package.pkg')
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:package_url)
        .and_return('http://package.com/package.pkg')
    end

    it 'returns an instance of Chef::Resource::RemoteFile' do
      res = provider.send(:remote_file)
      expect(res.class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#package_url' do
    let(:chefdk_version) { '0.1.0-1' }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:new_resource)
        .and_return(new_resource)
    end

    {
      'ubuntu' => { '12.04' => 'https://opscode-omnibus-packages.s3.' \
                               'amazonaws.com/ubuntu/12.04/x86_64/' \
                               'chefdk_0.1.0-1_amd64.deb',
                    '13.10' => 'https://opscode-omnibus-packages.s3.' \
                               'amazonaws.com/ubuntu/13.10/x86_64/' \
                               'chefdk_0.1.0-1_amd64.deb' },
      'redhat' => { '6.0' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.1.0-1.el6.x86_64.rpm',
                    '6.5' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.1.0-1.el6.x86_64.rpm' },
      'centos' => { '6.0' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.1.0-1.el6.x86_64.rpm',
                    '6.5' => 'https://opscode-omnibus-packages.s3.' \
                             'amazonaws.com/el/6/x86_64/' \
                             'chefdk-0.1.0-1.el6.x86_64.rpm' },
      'mac_os_x' => { '10.9.2' =>  'https://opscode-omnibus-packages.s3.' \
                                   'amazonaws.com/mac_os_x/10.9/x86_64/' \
                                   'chefdk-0.1.0-1.dmg' }
    }.each do |os, versions|
      versions.each do |version, url|
        context "a #{os}-#{version} node" do
          let(:platform) { { platform: os, version: version } }

          it 'returns the correct full package URL' do
            expect(provider.send(:package_url)).to eq(url)
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

  describe '#local_package_path' do
    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:package_file)
        .and_return('test.deb')
    end

    it 'returns a path in the Chef file_cache_path' do
      expect(provider.send(:local_package_path)).to eq(
        '/var/chef/cache/test.deb'
      )
    end
  end

  describe '#package_file' do
    let(:chefdk_version) { '0.1.0-1' }

    before(:each) do
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:version)
        .and_return('0.1.0')
      allow_any_instance_of(Chef::Provider::ChefDK).to receive(:build)
        .and_return('1')
    end

    {
      'ubuntu' => { '12.04' => 'chefdk_0.1.0-1_amd64.deb',
                    '13.10' => 'chefdk_0.1.0-1_amd64.deb' },
      'redhat' => { '6.0' => 'chefdk-0.1.0-1.el6.x86_64.rpm',
                    '6.5' => 'chefdk-0.1.0-1.el6.x86_64.rpm' },
      'centos' => { '6.0' => 'chefdk-0.1.0-1.el6.x86_64.rpm',
                    '6.5' => 'chefdk-0.1.0-1.el6.x86_64.rpm' },
      'mac_os_x' => { '10.9.2' => 'chefdk-0.1.0-1.dmg' }
    }.each do |os, versions|
      versions.each do |version, filename|
        context "a #{os}-#{version} node" do
          before(:each) do
            allow_any_instance_of(Chef::Provider::ChefDK).to receive(:extension)
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

  describe '#base_url' do
    it 'returns the base S3 bucket all the packages are under' do
      expect(provider.send(:base_url)).to eq(base_url)
    end
  end
end
