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

require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A Chef resource for the Chef-DK .rpm packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkAppRhel < ChefDkApp
      provides :chef_dk_app, platform_family: 'rhel'
      provides :chef_dk_app, platform: 'fedora'

      #
      # Depending on the specified source, download and install Chef-DK based
      # on the Omnitruck API, configure and install it from YUM, or install it
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
          rpm_package local_path
        when :repo
          include_recipe "yum-chef::#{new_resource.channel}"
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
          rpm_package local_path
        end
      end

      #
      # The YUM repository is shared between Chef, Chef-DK, etc. so all we can
      # confidently do for removal is to remove the package.
      #
      action :remove do
        package('chefdk') { action :remove }
      end
    end
  end
end
