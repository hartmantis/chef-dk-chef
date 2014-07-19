# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource/chef_dk
#
# Copyright 2014, Jonathan Hartman
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

require 'chef/resource'
require_relative 'provider_chef_dk'
require_relative 'provider_chef_dk_debian'
require_relative 'provider_chef_dk_mac_os_x'
require_relative 'provider_chef_dk_rhel'
require_relative 'provider_chef_dk_windows'

class Chef
  class Resource
    # A Chef resource for the Chef-DK packages
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDk < Resource
      attr_accessor :installed

      alias_method :installed?, :installed

      def initialize(name, run_context = nil)
        super
        @resource_name = :chef_dk
        @provider = determine_provider
        @action = :install
        @version = 'latest'
        @package_url = nil
        @allowed_actions = [:install, :uninstall]

        @installed = false
      end

      #
      # The version of Chef-DK to install
      #
      # @param [String] arg
      # @return [String]
      #
      def version(arg = nil)
        set_or_return(:version,
                      arg,
                      kind_of: String,
                      callbacks: {
                        'Can\'t set both a `version` and a `package_url`' =>
                          ->(_) { package_url.nil? }
                      })
      end

      #
      # Optinally override the calculated package URL
      #
      # @param [String] arg
      # @return [String]
      #
      def package_url(arg = nil)
        set_or_return(:package_url,
                      arg,
                      kind_of: [String, NilClass],
                      callbacks: {
                        'Can\'t set both a `package_url` and a `version`' =>
                          ->(_) { version == 'latest' }
                      })
      end

      private

      #
      # Determine what provider is to be used for this platform
      #
      # @return [Class]
      #
      def determine_provider
        return nil unless node && node['platform_family']
        platform = node['platform_family'].split('_').map do |i|
          i.capitalize
        end.join
        Chef::Provider::ChefDk.const_get(platform)
      end
    end
  end
end
