# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: chef_dk_helpers_metadata
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

require 'net/http'
require 'uri'

module ChefDk
  module Helpers
    # A helper class for the Chef package metadata service
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Metadata
      BASE_URL ||= 'https://www.opscode.com/chef'

      attr_reader :package_name, :node, :new_resource, :base_url

      def initialize(package_name, node, new_resource)
        @package_name = package_name
        @node = node
        @new_resource = new_resource
        @base_url = "#{BASE_URL}/metadata-#{package_name}"
      end

      #
      # Convert metadata into a hash
      #
      # @return [Hash]
      #
      def to_h
        raw_metadata.split("\n").each_with_object({}) do |line, hsh|
          case line.split[1]
          when 'true' then val = true
          when false then val = 'false'
          else val = line.split[1]
          end
          hsh[line.split[0].to_sym] = val
        end
      end

      #
      # Return the raw metadata string
      #
      # @return [String]
      #
      def to_s
        raw_metadata
      end

      private

      #
      # Get and return the raw metadata
      #
      # @return [String]
      #
      def raw_metadata
        @raw_metadata ||= Net::HTTP.get(URI(murl))
      end

      #
      # Construct the URL to pull metadata from
      #
      # @return [String]
      #
      def murl
        URI.encode(
          "#{base_url}?" << murl_elements.map { |k, v| "#{k}=#{v}" }.join('&')
        )
      end

      #
      # Return all the resource + platform needed to construct a metadata URL
      #
      # @return [Hash]
      #
      def murl_elements
        { v: new_resource.version,
          prerelease: new_resource.prerelease,
          nightlies: new_resource.nightlies,
          p: platform,
          pv: platform_version,
          m: machine }
      end

      #
      # The platform name to be used as a metadata URL element
      #
      # @return [String]
      #
      def platform
        node['platform']
      end

      #
      # The platform version to be used as a metadata URL element
      #
      # @return [String]
      #
      def platform_version
        case platform
        when 'mac_os_x'
          node['platform_version'].split('.')[0..1].join('.')
        else
          node['platform_version']
        end
      end

      #
      # The machine identifier to be used as a metadata URL element
      #
      # @return [String]
      #
      def machine
        node['kernel']['machine']
      end
    end
  end
end
