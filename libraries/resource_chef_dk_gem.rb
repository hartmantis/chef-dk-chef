# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_gem
#
# Copyright 2014-2016, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource/gem_package'
require 'chef/provider/package/rubygems'

class Chef
  class Resource
    # A resource for installing gem packages under Chef-DK's embedded Ruby.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkGem < GemPackage
      resource_name :chef_dk_gem

      # Override the :gem_binary to hit Chef-DK's embedded Ruby.
      property :gem_binary,
               String,
               desired_state: false,
               default: lazy {
                 case node['platform_family']
                 when 'windows'
                   ::File.expand_path('/opscode/chefdk/embedded/bin/gem')
                 else
                   ::File.expand_path('/opt/chefdk/embedded/bin/gem')
                 end
               }

      #
      # Overload the GemPackage constructor so we use Chef's built-in RubyGems
      # provider.
      #
      # (see Chef::Resource::GemPackage::initialize)
      #
      def initialize(name, run_context = nil)
        super
        @provider = Chef::Provider::Package::Rubygems
      end
    end
  end
end
