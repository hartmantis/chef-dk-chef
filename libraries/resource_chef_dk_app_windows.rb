# encoding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_windows
#
# Copyright 2014-2017, Jonathan Hartman
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

require 'chef/dsl/registry_helper'
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK Windows packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppWindows < ChefDkApp
      include Chef::DSL::RegistryHelper

      provides :chef_dk_app, platform_family: 'windows'

      action_class.class_eval do
        #
        # Download a .msi package file from the URL provided by the Omnitruck
        # API and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_direct!)
        #
        def install_direct!
          package package_name do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
        end

        #
        # Ensure Chocolatey is installed and install the Chef-DK Chocolatey
        # package.
        #
        # (see Chef::Resource::ChefDkApp#install_repo!)
        #
        def install_repo!
          if new_resource.channel != :stable
            raise(Chef::Exceptions::UnsupportedAction,
                  'A channel property cannot be used with the :repo source')
          end
          include_recipe 'chocolatey'
          chocolatey_package 'chefdk' do
            unless [nil, 'latest'].include?(new_resource.version)
              version new_resource.version
            end
          end
        end

        #
        # Download a .msi package file from a custom URL and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_custom!)
        #
        def install_custom!
          package package_name do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
        end

        #
        # Download the latest .msi package from the Omnitruck API and install
        # it.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_direct!)
        #
        def upgrade_direct!
          package "Chef Development Kit v#{package_metadata[:version]}" do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
        end

        #
        # Ensure Chocolatey is configured and pass an :upgrade action on to
        # a chefdk chocolatey_package resource.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_repo!)
        #
        def upgrade_repo!
          if new_resource.channel != :stable
            raise(Chef::Exceptions::UnsupportedAction,
                  'A channel property cannot be used with the :repo source')
          end
          include_recipe 'chocolatey'
          chocolatey_package 'chefdk' do
            action :upgrade
          end
        end

        #
        # The removal process is the same for either a direct or custom
        # install.
        #
        %w[remove_direct! remove_custom!].each do |m|
          define_method(m) do
            return unless current_resource.version

            package(registry_info[:name]) { action :remove }
            directory ::File.expand_path('~/AppData/Local/chefdk') do
              recursive true
              action :delete
            end
          end
        end

        #
        # For Chocolatey installations, remove Chef-DK by passing a :remove
        # action on to the underlying chocolatey_package resource.
        #
        # (see Chef::Resource::ChefDkApp#remove_repo!)
        #
        def remove_repo!
          chocolatey_package('chefdk') { action :remove }
        end

        #
        # Determine and return the name of the Windows package. This can be
        # tricky because the package name includes the version string.
        #
        # @return [String] The name for a windows_package resource
        #
        def package_name
          ver = if new_resource.version == 'latest'
                  package_metadata[:version]
                else
                  new_resource.version
                end
          "Chef Development Kit v#{ver}"
        end
      end

      #
      # Fetch the installed version of the Chef-DK from the Windows registry.
      # Chef-DK is currently 32-bit only, but let's future-proof it slightly
      # and check for 64-bit packages as well.
      #
      # (see Chef::Provider::ChefDkApp#installed_version)
      #
      def installed_version
        return false if registry_info.nil?
        ver = registry_info[:version].split('.')[0..2].join('.')
        ver == package_metadata[:version] ? 'latest' : ver
      end

      #
      # Fetch existing Chef-DK information from the registry, returning the
      # package name and version or nil if it's not installed.
      #
      # @return [Hash,NilClass] a package name + version or nil
      #
      def registry_info
        registry_uninstall_entries.each do |key|
          data = registry_name_and_version(key)

          if data[:name] && \
             data[:version] && \
             data[:name].match(/^Chef Development Kit v/)
            return { name: data[:name], version: data[:version] }
          end
        end
        nil
      end

      #
      # Parse through an uninstall registry key and return its name and version.
      #
      # @param key [String] a registry key path
      #
      # @return [Hash] that key's name and version (or nil)
      #
      def registry_name_and_version(key)
        values = registry_get_values(key)
        nme = values.find { |p| p[:name] == 'DisplayName' }
        ver = values.find { |p| p[:name] == 'DisplayVersion' }
        { name: nme && nme[:data], version: ver && ver[:data] }
      end

      #
      # Return an list of all uninstall registry entries, both
      # 32-bit and 64-bit.
      #
      # @return [Array<String>] an array of registry paths
      #
      def registry_uninstall_entries
        registry_uninstall_paths.map do |path|
          registry_get_subkeys(path).map { |app| "#{path}\\#{app}" }
        end.flatten
      end

      #
      # Return the registry paths to look for Chef-DK uninstall information
      # under. While Chef-DK is currently 32-bit only, let's be slightly
      # future-proof and check the 64-bit path as well.
      #
      # @return [Array<String>] an array of registry paths
      #
      def registry_uninstall_paths
        [
          'HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\' \
            'Uninstall',
          'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
        ]
      end
    end
  end
end
