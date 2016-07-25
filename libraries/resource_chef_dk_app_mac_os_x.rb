# encoding: utf-8
# frozen_string_literal: true
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
      # Depending on the specified source, download and install Chef-DK based
      # on the Omnitruck API, configure and install it from Homebrew, or
      # install it from a custom source.
      #
      action :install do
        case new_resource.source
        when :direct
          dmg_package 'Chef Development Kit' do
            app ::File.basename(package_metadata[:url], '.dmg')
            volumes_dir 'Chef Development Kit'
            source package_metadata[:url]
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum package_metadata[:sha256]
          end
        when :repo
          include_recipe 'homebrew'
          homebrew_cask 'chefdk'
        else
          dmg_package 'Chef Development Kit' do
            app ::File.basename(new_resource.source.to_s, '.dmg')
            volumes_dir 'Chef Development Kit'
            source(
              (new_resource.source.to_s.start_with?('/') ? 'file://' : '') + \
              new_resource.source.to_s
            )
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum new_resource.checksum unless new_resource.checksum.nil?
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
          homebrew_cask('chefdk') { action :uninstall }
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
