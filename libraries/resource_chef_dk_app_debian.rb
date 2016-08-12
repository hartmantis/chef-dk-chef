# encoding: utf-8
# frozen_string_literal: true
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app_debian
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
    # A Chef resource for the Chef-DK .deb packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppDebian < ChefDkApp
      provides :chef_dk_app, platform_family: 'debian'

      #
      # Depending on the specified source, download and install Chef-DK based
      # on the Omnitruck API, configure and install it from APT, or install it
      # from a custom source.
      #
      action :install do
        case new_resource.source
        when :direct
          local_path = ::File.join(Chef::Config[:file_cache_path],
                                   ::File.basename(package_metadata[:url]))
          remote_file local_path do
            source package_metadata[:url]
            checksum package_metadata[:sha256]
          end
          dpkg_package local_path
        when :repo
          package 'apt-transport-https'
          include_recipe "apt-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version.nil?
          end
        else
          local_path = ::File.join(Chef::Config[:file_cache_path],
                                   ::File.basename(new_resource.source.to_s))
          remote_file local_path do
            source new_resource.source.to_s
            checksum new_resource.checksum unless new_resource.checksum.nil?
          end
          dpkg_package local_path
        end
      end

      #
      # Upgrade or install the Chef-DK. This action currently only supports the
      # :repo installation source.
      #
      action :upgrade do
        case new_resource.source
        when :direct
          raise(Chef::Exceptions::UnsupportedAction,
                'Direct installs do not support the :upgrade action')
        when :repo
          package 'apt-transport-https'
          include_recipe "apt-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version.nil?
            action :upgrade
          end
        else
          raise(Chef::Exceptions::UnsupportedAction,
                'Custom installs do not support the :upgrade action')
        end
      end

      #
      # The APT repository is shared between Chef, Chef-DK, etc. so all we can
      # confidently do for removal is to remove the package.
      #
      action :remove do
        package('chefdk') { action :purge }
      end
    end
  end
end
