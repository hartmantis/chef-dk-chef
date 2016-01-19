# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk_rhel
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

require 'chef/provider/lwrp_base'
require_relative 'provider_chef_dk'

class Chef
  class Provider
    class ChefDk < LWRPBase
      # A Chef provider for the Chef-DK .rpm packages.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Rhel < ChefDk
        provides :chef_dk, platform_family: 'rhel'
        provides :chef_dk, platform: 'fedora'

        private

        #
        # Download and install the Chef-DK .rpm. The `rpm_package` resource
        # doesn't accept a remote source, so this must be done in two steps.
        #
        # (see Chef::Provider::ChefDk#install!)
        #
        def install!
          src = package_source
          dst = ::File.join(Chef::Config[:file_cache_path],
                            ::File.basename(src))
          remote_file dst do
            source src
          end
          rpm_package dst
        end

        #
        # Use the normal `package` resource to remove the Chef-DK.
        #
        # (see Chef::Provider::ChefDk#remove!)
        #
        def remove!
          package 'chefdk' do
            action :remove
          end
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
