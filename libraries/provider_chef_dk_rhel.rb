# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider/chef_dk_rhel
#
# Copyright 2014, Jonathan Hartman
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
        # Override the platform name used in the package URL
        # (RHEL and RHELalikes use "el")
        #
        # @return [String]
        #
        def platform
          'el'
        end

        #
        # Override the platform version used in the package URL
        # (RHEL and RHELalikes use the major version only)
        #
        # @return [String]
        #
        def platform_version
          node['platform_version'].to_i.to_s
        end

        #
        # Override the elements used to assemble a package file name
        # (RHEL and RHELalikes use the pla
        #
        # @return [Array]
        #
        def package_file_elements
          [
            PACKAGE_NAME,
            "#{version}.#{platform}#{platform_version}." <<
              node['kernel']['machine']
          ]
        end

        #
        # Return the extension of package files used by this system
        #
        # @return [String]
        #
        def package_file_extension
          '.rpm'
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
