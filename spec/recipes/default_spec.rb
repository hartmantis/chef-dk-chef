# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: recipes/default
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

require 'spec_helper'

describe 'chef-dk::default' do
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::Runner.new do |node|
      overrides.each do |k, v|
        node.set['chef_dk'][k] = v
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'with default attributes' do
    it 'installs the latest version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: 'latest')
    end
  end

  context 'an overridden `version` attribute' do
    let(:overrides) { { version: '1.2.3-4' } }

    it 'installs the specified version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: '1.2.3-4')
    end
  end

  context 'an overridden `package_url` attribute' do
    let(:overrides) { { package_url: 'http://example.com/pkg.pkg' } }

    it 'installs from the desired package URL' do
      expect(chef_run).to install_chef_dk('chef_dk')
        .with(package_url: 'http://example.com/pkg.pkg')
    end
  end

  context 'overridden `version` and `package_url` attributes' do
    let(:overrides) do
      { version: '1.2.3-4', package_url: 'http://example.com/pkg.pkg' }
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_exception(Chef::Exceptions::ValidationFailed)
    end
  end
end
