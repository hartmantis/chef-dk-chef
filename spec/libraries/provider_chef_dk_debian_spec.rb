# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: provider_chef_dk_debian
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
require_relative '../../libraries/provider_chef_dk_debian'

describe Chef::Provider::ChefDk::Debian do
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
    it 'returns Chef::Provider::Package::Dpkg' do
      expected = Chef::Provider::Package::Dpkg
      expect(provider.send(:package_provider_class)).to eq(expected)
    end
  end

  describe '#bashrc_file' do
    it 'returns "bash.bashrc"' do
      expect(provider.send(:bashrc_file)).to eq('/etc/bash.bashrc')
    end
  end
end
