# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: resource/chef_dk
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
require_relative '../../libraries/resource_chef_dk'

describe Chef::Resource::ChefDk do
  let(:version) { nil }
  let(:package_url) { nil }
  let(:resource) do
    r = Chef::Resource::ChefDk.new('my_chef_dk', nil)
    r.version(version)
    r.package_url(package_url)
    r
  end

  describe '#initialize' do
    it 'defaults to the latest version' do
      expect(resource.instance_variable_get(:@version)).to eq('latest')
    end

    it 'defaults the state to uninstalled' do
      expect(resource.installed?).to eq(false)
    end
  end

  describe '#version' do
    context 'with no version override provided' do
      it 'defaults to the latest version' do
        expect(resource.version).to eq('latest')
      end
    end

    context 'with a version override provided' do
      let(:version) { '1.2.3-4' }

      it 'returns the overridden version' do
        expect(resource.version).to eq(version)
      end
    end

    context 'with a version AND package_url provided' do
      let(:version) { '1.2.3-4' }
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it 'raises an exception' do
        expect { resource.version }.to raise_error(
          Chef::Exceptions::ValidationFailed
        )
      end
    end
  end

  describe '#package_url' do
    context 'with no override provided' do
      it 'defaults to nil to let the provider calculate a URL' do
        expect(resource.package_url).to eq(nil)
      end
    end

    context 'with a package_url override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it 'returns the overridden package_url' do
        expect(resource.package_url).to eq(package_url)
      end
    end

    context 'with a package_url AND version override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }
      let(:version) { '1.2.3-4' }

      it 'raises an exception' do
        expect { resource.package_url }.to raise_error(
          Chef::Exceptions::ValidationFailed
        )
      end
    end
  end
end
