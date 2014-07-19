# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider/chef_dk_rhel
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
require_relative '../../libraries/provider_chef_dk_rhel'

describe Chef::Provider::ChefDk::Rhel do
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

  describe '#package_provider_class' do
    it 'returns Chef::Provider::Package::Rpm' do
      expected = Chef::Provider::Package::Rpm
      expect(provider.send(:package_provider_class)).to eq(expected)
    end
  end

  describe '#platform' do
    it 'returns "el"' do
      expect(provider.send(:platform)).to eq('el')
    end
  end

  describe '#platform_version' do
    {
      '7.0' => '7',
      '6.5' => '6',
      '5.10' => '5'
    }.each do |full_version, major_version|
      context "a centos-#{full_version} node" do
        let(:platform) { { platform: 'centos', version: full_version } }

        it 'returns the major version, "#{major_version}"' do
          expect(provider.send(:platform_version)).to eq(major_version)
        end
      end
    end
  end

  describe '#package_file_elements' do
    let(:platform) { { platform: 'centos', version: '6.5' } }

    it 'returns the elements to assemble into a RHEL file name' do
      expected = %w(chefdk 0.2.0-2.el6.x86_64)
      expect(provider.send(:package_file_elements)).to eq(expected)
    end
  end

  describe '#package_file_extension' do
    it 'returns the ".rpm" extension' do
      expect(provider.send(:package_file_extension)).to eq('.rpm')
    end
  end
end
