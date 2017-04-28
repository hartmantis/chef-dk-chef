# encoding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_debian
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

require 'chef/provider/package/dpkg'
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK .deb packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppDebian < ChefDkApp
      provides :chef_dk_app, platform_family: 'debian'

      action_class.class_eval do
        #
        # Download a .deb package file from the URL provided by the Omnitruck
        # API and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_direct!)
        #
        def install_direct!
          remote_file local_path do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
          dpkg_package local_path
        end

        #
        # Configure the Chef APT repository and install the Chef-DK package
        # from there.
        #
        # (see Chef::Resource::ChefDkApp#install_repo!
        #
        def install_repo!
          package 'apt-transport-https'
          include_recipe "apt-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
          end
        end

        #
        # Download a .deb package file from a custom URL and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_custom!)
        #
        def install_custom!
          remote_file local_path do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
          dpkg_package local_path
        end

        #
        # Download the latest .deb package from the Omnitruck API and install
        # it.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_direct!)
        #
        def upgrade_direct!
          remote_file local_path do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
          dpkg_package local_path
        end

        #
        # Ensure the Chef APT repo is configured and pass an :upgrade action
        # on to a chefdk package resource.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_repo!)
        #
        def upgrade_repo!
          package 'apt-transport-https'
          include_recipe "apt-chef::#{new_resource.channel}"
          package('chefdk') { action :upgrade }
        end

        #
        # We can't be certain that the Chef APT repo is only being used for
        # Chef-DK, so the remove action is just a package purge regardless of
        # installation type.
        #
        %w[remove_direct! remove_repo! remove_custom!].each do |m|
          define_method(m) { package('chefdk') { action :purge } }
        end
      end

      #
      # Use Chef's Package resource and Dpkg provider to find the currently
      # installed version.
      #
      # (see Chef::Resource::ChefDkApp#installed_version)
      #
      def installed_version
        res = Chef::Resource::Package.new('chefdk', run_context)
        prov = Chef::Provider::Package::Dpkg.new(res, run_context)
        ver = prov.load_current_resource.version.first
        return false if ver.nil?
        ver = ver.split('-').first
        ver == package_metadata[:version] ? 'latest' : ver
      end
    end
  end
end
