# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider/chef_dk_mac_os_x
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
require_relative '../../libraries/provider_chef_dk_mac_os_x'

describe Chef::Provider::ChefDk::MacOsX do
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

  describe '#tailor_package_resource_to_platform' do
    let(:package) do
      double(app: true, source: true, type: true, package_id: true)
    end
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
    end

    it 'calls `app` with the package name' do
      expect(package).to receive(:app).with('chefdk')
      provider.send(:tailor_package_resource_to_platform)
    end

    it 'calls `source` with the local file path' do
      expect(package).to receive(:source).with('file:///tmp/blah.pkg')
      provider.send(:tailor_package_resource_to_platform)
    end

    it 'calls `type` with `pkg`' do
      expect(package).to receive(:type).with('pkg')
      provider.send(:tailor_package_resource_to_platform)
    end

    it 'calls `package_id` with `com.getchef.pkg.chefdk`' do
      expect(package).to receive(:package_id).with('com.getchef.pkg.chefdk')
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns the DmgPackage resource' do
      expected = Chef::Resource::DmgPackage
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#platform_version' do
    %w(10.7.4 10.8.2 10.9.2).each do |v|
      context "a mac_os_x-#{v} node" do
        let(:platform) { { platform: 'mac_os_x', version: v } }

        it 'returns `10.9`' do
          expect(provider.send(:platform_version)).to eq('10.9')
        end
      end
    end
  end

  describe '#package_file_extension' do
    it 'returns the `.dmg` extension' do
      expect(provider.send(:package_file_extension)).to eq('.dmg')
    end
  end
end
