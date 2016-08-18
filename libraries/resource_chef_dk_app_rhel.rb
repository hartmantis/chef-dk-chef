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

      #
      # Determine whether the package is currently installed.
      #
      load_current_value do
        version(installed_version)
        installed(version == false ? false : true)
      end

      #
      # Depending on the specified source, download and install Chef-DK based
      # on the Omnitruck API, configure and install it from YUM, or install it
      # from a custom source.
      #
      action :install do
        case new_resource.source
        when :direct
          new_resource.installed(true)

          converge_if_changed :installed do
            local_path = ::File.join(Chef::Config[:file_cache_path],
                                     ::File.basename(package_metadata[:url]))
            remote_file local_path do
              source package_metadata[:url]
              checksum package_metadata[:sha256]
            end
            rpm_package local_path
          end
        when :repo
          include_recipe "yum-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
          end
        else
          new_resource.installed(true)

          converge_if_changed :installed do
            local_path = ::File.join(Chef::Config[:file_cache_path],
                                     ::File.basename(new_resource.source.to_s))
            remote_file local_path do
              source new_resource.source.to_s
              checksum new_resource.checksum unless new_resource.checksum.nil?
            end
            rpm_package local_path
          end
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
          include_recipe "yum-chef::#{new_resource.channel}"
          package 'chefdk' do
            version new_resource.version unless new_resource.version == 'latest'
            action :upgrade
          end
        else
          raise(Chef::Exceptions::UnsupportedAction,
                'Custom installs do not support the :upgrade action')
        end
      end

      #
      # The YUM repository is shared between Chef, Chef-DK, etc. so all we can
      # confidently do for removal is to remove the package.
      #
      action :remove do
        rpm_package('chefdk') { action :remove }
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
