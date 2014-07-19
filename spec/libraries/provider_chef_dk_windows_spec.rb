# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider/chef_dk_windows
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
require_relative '../../libraries/provider_chef_dk_windows'

describe Chef::Provider::ChefDk::Windows do
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
    stub_const('::File::ALT_SEPARATOR', '\\')
  end

  describe '#tailor_package_resource_to_platform' do
    let(:package) { double(source: true) }
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.msi')
    end

    it 'calls `source` with the local file path' do
      expect(package).to receive(:source).with('/tmp/blah.msi')
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns Chef::Resource::WindowsPackage' do
      expected = Chef::Resource::WindowsPackage
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#platform_version' do
    %w(2012 2008R2).each do |v|
      context "a windows-#{v} node" do
        let(:platform) { { platform: 'windows', version: v } }

        it 'returns "2008r2"' do
          expect(provider.send(:platform_version)).to eq('2008r2')
        end
      end
    end
  end

  describe '#package_file_elements' do
    it 'returns the standard elements + a couple of "windows"' do
      expected = %w(chefdk windows 0.2.0-2.windows)
      expect(provider.send(:package_file_elements)).to eq(expected)
    end
  end

  describe '#package_file_extension' do
    it 'returns ".msi"' do
      expect(provider.send(:package_file_extension)).to eq('.msi')
    end
  end
end
