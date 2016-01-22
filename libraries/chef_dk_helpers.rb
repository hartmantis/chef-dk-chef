# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: chef_dk_helpers
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

require 'chef/util/file_edit'

module ChefDk
  # A set of helper methods for the chef-dk cookbook.
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  class Helpers
    class << self
      #
      # Get the package metadata.
      #
      # @param node [Chef::Node] a Chef node instance
      # @param new_resource [Chef::Resource::ChefDk] a ChefDk resource
      #
      # @return [Hash,NilClass] package metadata from the Omnitruck API
      #
      def metadata_for(node, new_resource)
        return nil if new_resource.package_url
        require 'omnijack'
        params = metadata_params_for(node, new_resource)
        m = Omnijack::Project::ChefDk.new(params).metadata
        m.yolo && Chef::Log.warn('Using a ChefDk package not officially ' \
                                 'supported on this platform')
        m
      end

      #
      # Construct the hash of parameters for Omnijack to get the right metadata
      #
      # @param node [Chef::Node] a Chef node instance
      # @param new_resource [Chef::Resource::ChefDk] a ChefDk resource
      #
      # @return [Hash] properties required to fetch package metadata
      #
      def metadata_params_for(node, new_resource)
        { platform: node['platform'],
          platform_version: node['platform_version'],
          machine_arch: node['kernel']['machine'],
          version: new_resource.version,
          prerelease: new_resource.prerelease,
          nightlies: new_resource.nightlies }
      end

      #
      # Determine whether string is a valid package version
      #
      # @param [String] arg
      # @return [TrueClass, FalseClass]
      #
      def valid_version?(arg)
        return true if arg == 'latest'
        arg =~ /^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?$/ ? true : false
      end
    end
  end
end
