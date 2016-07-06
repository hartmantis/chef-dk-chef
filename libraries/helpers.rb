# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: helpers
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

require 'uri'
require 'net/http'

module ChefDk
  # A set of helper methods for the chef-dk cookbook.
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  class Helpers
    class << self
      #
      # Fetch and return the metadata for a Chef-DK package from the Omnitruck
      # API. Options required to find such metadata are:
      #
      #   * channel - 'stable' or 'current'
      #   * version - a version string or 'latest'
      #   * platform - a platform name
      #   * platform_version - a platform version
      #   * machine - 'x86_64' or 'i386'
      #
      # @param options [Hash] a hash of package options
      #
      # @return [Hash, NilClass] the package metadata or nil
      #
      def metadata_for(options)
        base = "https://omnitruck.chef.io/#{options.fetch(:channel)}/chefdk/" \
               'metadata'
        params = [['v', options.fetch(:version)],
                  ['p', options.fetch(:platform)],
                  ['pv', options.fetch(:platform_version)],
                  ['m', options.fetch(:machine)]]
        body = Net::HTTP.get(URI("#{base}?#{URI.encode_www_form(params)}"))
        body.empty? ? nil : parse_metadata_body(body)
      end

      #
      # Take the string body returned from the Omnitruck API and convert it
      # into a hash.
      #
      # @param body [String] the body
      #
      # @return [Hash] the body parsed into a hash
      #
      def parse_metadata_body(body)
        body.lines.each_with_object({}) do |line, hsh|
          k, v = line.strip.split
          hsh[k.to_sym] = v
        end
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
