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

require 'chef/mixin/shell_out'
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK Mac OS X packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppMacOsX < ChefDkApp
      include Chef::Mixin::ShellOut

      provides :chef_dk_app, platform_family: 'mac_os_x'

      action_class.class_eval do
        #
        # Download a MacOS package file from the URL provided by the Omnitruck
        # API and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_direct!
        #
        def install_direct!
          dmg_package 'Chef Development Kit' do
            app ::File.basename(package_metadata[:url], '.dmg')
            volumes_dir 'Chef Development Kit'
            source package_metadata[:url]
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum package_metadata[:sha256]
          end
        end

        #
        # Configure Homebrew and install the Chef-DK cask.
        #
        # (see Chef::Resource::ChefDkApp#install_repo!
        #
        def install_repo!
          include_recipe 'homebrew'
          homebrew_cask 'chefdk'
        end

        #
        # Download a MacOS package file from a custom URL and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_custom!
        #
        def install_custom!
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

        #
        # Download the latest MacOS package from the Omnitruck API and install
        # it.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_direct!)
        #
        def upgrade_direct!
          dmg_package 'Chef Development Kit' do
            app ::File.basename(package_metadata[:url], '.dmg')
            volumes_dir 'Chef Development Kit'
            source package_metadata[:url]
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum package_metadata[:sha256]
          end
        end

        #
        # There is no upgrade option for Homebrew casks, so raise an error.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_repo!)
        #
        def upgrade_repo!
          raise(Chef::Exceptions::UnsupportedAction,
                'Repo installs do not support the :upgrade action')
        end

        #
        # For non-repo installs, all we can do is clean up the app directories
        # manually and forget the chefdk package from pkgutil.
        #
        %i(remove_direct! remove_custom!).each do |m|
          define_method(m) do
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

        #
        # Uninstall the Chef-DK brew cask.
        #
        # (see Chef::Resource::ChefDkApp#remove_repo!)
        #
        def remove_repo!
          homebrew_cask('chefdk') { action :uninstall }
        end
      end

      #
      # Shell out to pkgutil to find the installed version of the Chef-DK.
      #
      # @return [String, FalseClass] "major.minor.patch", "latest", or false
      #
      def installed_version
        sh = shell_out('pkgutil --pkg-info com.getchef.pkg.chefdk')
        return false if sh.exitstatus.nonzero?
        ver = sh.stdout.match(/^version:\W+([0-9]+\.[0-9]+\.[0-9]+)$/)[1]
        ver == package_metadata[:version] ? 'latest' : ver
      end
    end
  end
end
