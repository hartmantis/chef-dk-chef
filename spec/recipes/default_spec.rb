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
  let(:runner) { ChefSpec::Runner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  context 'with default attributes' do
    it 'installs the latest version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: 'latest')
    end
  end

  context 'an overridden version attribute' do
    let(:runner) do
      ChefSpec::Runner.new do |node|
        node.set['chef_dk']['version'] = '1.2.3-4'
      end
    end

    it 'installs the specified version of the Chef-DK' do
      expect(chef_run).to install_chef_dk('chef_dk').with(version: '1.2.3-4')
    end
  end
end
