# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_rhel
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

require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK .rpm packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppRhel < ChefDkApp
      provides :chef_dk_app, platform_family: 'rhel'
      provides :chef_dk_app, platform: 'fedora'

      #
      # Download and install the Chef-DK .rpm. The `rpm_package` resource
      # doesn't accept a remote source, so this must be done in two steps.
      #
      action :install do
        src = package_source
        dst = ::File.join(Chef::Config[:file_cache_path],
                          ::File.basename(src))
        chk = package_checksum
        remote_file dst do
          source src
          checksum chk
        end
        rpm_package dst
      end

      #
      # Use the `rpm_package` resource to remove the Chef-DK.
      #
      action :remove do
        package 'chefdk' do
          action :remove
        end
      end
    end
  end
end
