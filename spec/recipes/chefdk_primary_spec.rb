# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: recipes/chefdk_primary_spec.rb
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

describe 'chef-dk::chefdk_primary' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::Runner.new(platform) do |node|
      overrides.each do |k, v|
        node.set['chef_dk'][k] = v
      end
    end
  end

  let(:chef_run) { runner.converge(described_recipe) }

  it 'includes the default recipe' do
    expect(chef_run).to include_recipe('chef-dk')
  end
end
