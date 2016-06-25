# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_mac_os_x
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
    # A Chef resource for the Chef-DK Mac OS X packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppMacOsX < ChefDkApp
      provides :chef_dk_app, platform_family: 'mac_os_x'

      #
      # Use a dmg_package resource to download and install Chef-DK.
      #
      action :install do
        case new_resource.source
        when :direct
          src = package_source
          chk = package_checksum
          dmg_package 'Chef Development Kit' do
            app ::File.basename(src, '.dmg')
            volumes_dir 'Chef Development Kit'
            source "#{'file://' if src.start_with?('/')}#{src}"
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum chk
          end
        when :repo
          raise unless new_resource.channel == :stable
          include_recipe 'homebrew'
          homebrew_cask '???'
          homebrew_package 'chefdk'
        else
          local_path = ::File.join(Chef::Config[:file_cache_path],
                                   ::File.basename(new_resource.source.to_s))
          remote_file local_path do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
          dmg_package 'Chef Development Kit' do
            app ::File.basename(src, '.dmg')
            volumes_dir 'Chef Development Kit'
            source "#{'file://' if src.start_with?('/')}#{src}"
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum chk
          end
        end
      end

      #
      # Clean up the package directories and forget the Chef-DK entry in
      # pkgutil.
      #
      action :remove do
        case new_resource.source
        when :repo
          homebrew_package('chefdk') { action :remove }
        else
          ['/opt/chefdk', ::File.expand_path('~/.chefdk')].each do |d|
            directory d do
              recursive true
              action :delete
            end
          end
          execute 'pkgutil --forget com.getchef.pkg.chefdk' do
            only_if 'pkgutil --pkg-info com.getchef.pkg.chefdk'
          end
        end
      end
    end
  end
end
