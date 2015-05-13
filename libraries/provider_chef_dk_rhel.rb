# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk_rhel
#
# Copyright 2014-2015 Jonathan Hartman
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

require 'chef/provider'
require 'chef/provider/package/rpm'
require_relative 'provider_chef_dk'
require_relative 'resource_chef_dk'

class Chef
  class Provider
    class ChefDk < Provider
      # A Chef provider for the Chef-DK .rpm packages
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Rhel < ChefDk
        private

        #
        # Override the provider of the package resource
        #
        # @return [Class]
        #
        def package_provider_class
          Chef::Provider::Package::Rpm
        end

        #
        # Return the global bashrc file path for this system
        #
        # @return [String]
        #
        def bashrc_file
          '/etc/bashrc'
        end
      end
    end
  end
end
