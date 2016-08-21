# encoding: utf-8
# frozen_string_literal: true
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

require 'chef/mixin/shell_out'
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK .rpm packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppRhel < ChefDkApp
      include Chef::Mixin::ShellOut

      provides :chef_dk_app, platform_family: 'rhel'
      provides :chef_dk_app, platform: 'fedora'

      action_class.class_eval do
        #
        # Download a .rpm package file from a URL provided by the Omnitruck
        # API and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_direct!)
        #
        def install_direct!
          remote_file local_path do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
          rpm_package local_path
        end

        #
        # Configure the Chef YUM repository and install the Chef-DK package
        # from there.
        #
        # (see Chef::Resource::ChefDkApp#install_repo!
        #
        def install_repo!
          include_recipe "yum-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
          end
        end

        #
        # Download a .rpm package file from a custom URL and install it.
        #
        # (see Chef::Resource::ChefDkApp#install_custom!
        #
        def install_custom!
          remote_file local_path do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
          rpm_package local_path
        end

        #
        # Download the latest .rpm package from the Omnitruck API and install
        # it.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_direct!
        #
        def upgrade_direct!
          remote_file local_path do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
          rpm_package local_path
        end

        #
        # Ensure the Chef YUM repo is configured and pass an :upgrade action
        # on to a chefdk package resource.
        #
        # (see Chef::Resource::ChefDkApp#upgrade_repo!)
        #
        def upgrade_repo!
          include_recipe "yum-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
            action :upgrade
          end
        end

        #
        # We can't be certain that the Chef YUM rpo is only being used for
        # Chef-DK, so the remove action is just a package removal regardless
        # of installation type.
        #
        %w(remove_direct! remove_repo! remove_custom!).each do |m|
          define_method(m) { rpm_package('chefdk') { action :remove } }
        end
      end

      #
      # Shell out to the RPM command to get the currently installed version.
      # We can't use a Chef provider here because the Rpm provider requires a
      # source property that we don't have and the Yum provider has issues on
      # Fedora.
      #
      # (see Chef::Resource::ChefDkApp#installed_version)
      #
      def installed_version
        sh = shell_out('rpm -q --info chefdk')
        return false if sh.exitstatus.nonzero?
        ver = sh.stdout.match(/^Version\W+:\W+([0-9]+\.[0-9]+\.[0-9]+)/)[1]
        ver == package_metadata[:version] ? 'latest' : ver
      end
    end
  end
end
