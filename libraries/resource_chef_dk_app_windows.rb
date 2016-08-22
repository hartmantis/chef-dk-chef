# encoding: utf-8
# frozen_string_literal: true
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

require 'chef/mixin/powershell_out'
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK Windows packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppWindows < ChefDkApp
      include Chef::Mixin::PowershellOut

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
          include_recipe 'chocolatey'
          chocolatey_package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
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
          include_recipe 'chocolatey'
          chocolatey_package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
            action :upgrade
          end
        end

        #
        # The removal process is the same for either a direct or custom
        # install.
        #
        %w(remove_direct! remove_custom!).each do |m|
          define_method(m) do
            lines = powershell_out!('Get-WmiObject -Class win32_product').stdout
                                                                         .lines
            idx = lines.index do |l|
              l.match(/^\W*Name\W+:\W+Chef Development Kit/)
            end

            if idx
              name = lines[idx].split(':')[1].strip
              idn = lines[idx - 1].split(':')[1].strip
              execute "Uninstall #{name}" do
                command "msiexec /qn /x \"#{idn}\""
              end
            else
              package('Chef Development Kit') { action :remove }
            end
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

      #
      # Powershell out and pull the version of the Chef-DK out of
      # Get-WmiObject.
      #
      # (see Chef::Provider::ChefDkApp#installed_version)
      #
      def installed_version
        lines = powershell_out!('Get-WmiObject -Class win32_product')
                .stdout.lines
        idx = lines.index do |l|
          l.match(/^\W*Name\W+:\W+Chef Development Kit/)
        end
        return false if idx.nil?
        ver = lines[idx + 2].match(/:\W+([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/)[1]
        ver == package_metadata[:version] ? 'latest' : ver
      end
    end
  end
end
