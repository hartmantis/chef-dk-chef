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
          do_dmg_package_resource!
        end

        #
        # Configure Homebrew and install the Chef-DK cask.
        #
        # (see Chef::Resource::ChefDkApp#install_repo!
        #
        def install_repo!
          if new_resource.version != 'latest'
            raise(Chef::Exceptions::UnsupportedAction,
                  'A version property cannot be used with the :repo source')
          end
          if new_resource.channel != :stable
            raise(Chef::Exceptions::UnsupportedAction,
                  'A channel property cannot be used with the :repo source')
          end
          include_recipe 'homebrew'
          homebrew_cask 'chefdk'
        end

        #
        # Download a MacOS package file from a custom URL and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_custom!
        #
        def install_custom!
          do_dmg_package_resource!
        end

        #
        # Download the latest MacOS package from the Omnitruck API and install
        # it.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_direct!)
        #
        def upgrade_direct!
          do_dmg_package_resource!
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

        #
        # Perform the appropriate action with a dmg_package resource that can
        # be shared between direct and custom installs.
        #
        def do_dmg_package_resource!
          dmg_package 'Chef Development Kit' do
            app dmg_package_app
            volumes_dir 'Chef Development Kit'
            source dmg_package_source
            type 'pkg'
            package_id 'com.getchef.pkg.chefdk'
            checksum dmg_package_checksum
          end
        end

        #
        # Determine the checksum for a given package. This comes from Omnitruck
        # for an Omnitruck-based install or can be fed in by the user for a
        # custom install.
        #
        # @return [String, NilClass] A checksum string or nil
        #
        def dmg_package_checksum
          case new_resource.source
          when :direct
            package_metadata[:sha256]
          else
            new_resource.checksum
          end
        end

        #
        # Determine the app name for a given package. This can normally be
        # found by stripping the '.dmg' off the end of the package file.
        #
        # @return [String] A dmg_package app name
        #
        def dmg_package_app
          case new_resource.source
          when :direct
            ::File.basename(package_metadata[:url], '.dmg')
          else
            ::File.basename(new_resource.source.to_s, '.dmg')
          end
        end

        #
        # Return the correct source string for a given path. For the
        # dmg_package resource, sources that are paths on the filesystem have
        # to start with "file://".
        #
        # @return [String] That path ready to be fed to a dmg_package
        #
        def dmg_package_source
          if %i(direct repo).include?(new_resource.source)
            return package_metadata[:url]
          end
          path = new_resource.source.to_s
          (path.start_with?('/') ? 'file://' : '') + path
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
