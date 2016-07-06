# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_windows
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
    # A Chef resource for the Chef-DK Windows packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppWindows < ChefDkApp
      provides :chef_dk_app, platform_family: 'windows'

      #
      # Use a windows_package resource to install the Chef-DK.
      #
      action :install do
        case new_resource.source
        when :direct
          windows_package 'Chef Development Kit' do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
        when :repo
          include_recipe 'chocolatey'
          chocolatey_package 'chefdk' do
            version new_resource.version unless new_resource.version.nil?
          end
        else
          windows_package 'Chef Development Kit' do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
        end
      end

      #
      # Use a windows_package resource to remove the Chef-DK.
      #
      action :remove do
        case new_resource.source
        when :repo
          chocolatey_package('chefdk') { action :purge }
        else
          windows_package('Chef Development Kit') { action :remove }
        end
      end
    end
  end
end
