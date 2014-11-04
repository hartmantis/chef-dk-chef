# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Spec:: spec_helper
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

require 'chef'
require 'chefspec'
require 'json'
require 'tempfile'
require 'simplecov'
require 'simplecov-console'
require 'coveralls'
require 'tmpdir'
require 'fileutils'
require_relative 'support/provider/dmg_package'
require_relative 'support/resource/dmg_package'
require_relative 'support/matchers/chef_dk'

RSpec.configure do |c|
  c.color = true

  c.before(:suite) do
    COOKBOOK_PATH = Dir.mktmpdir 'chefspec'
    metadata = Chef::Cookbook::Metadata.new
    metadata.from_file(File.expand_path('../../metadata.rb', __FILE__))
    link_path = File.join(COOKBOOK_PATH, metadata.name)
    FileUtils.ln_s(File.expand_path('../..', __FILE__), link_path)
    c.cookbook_path = COOKBOOK_PATH
  end

  c.before(:each) do
    # Don't worry about external cookbook dependencies
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:depends)

    # Prep lookup() for the stubs below
    allow_any_instance_of(Chef::ResourceCollection).to receive(:lookup)
      .and_call_original

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?)
      .and_return(false)
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe) do |_, i|
      allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipe?)
        .with(i)
        .and_return(true)
      @included_recipes << i
    end
    allow_any_instance_of(Chef::RunContext).to receive(:loaded_recipes)
      .and_return(@included_recipes)
  end

  c.after(:suite) { FileUtils.rm_r(COOKBOOK_PATH) }
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]
SimpleCov.minimum_coverage 90
SimpleCov.start

at_exit { ChefSpec::Coverage.report! }
