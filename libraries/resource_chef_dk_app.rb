# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_app
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

require 'chef/resource'
require_relative 'helpers'

class Chef
  class Resource
    # A Chef resource for the Chef-DK packages.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkApp < Resource
      default_action :install

      #
      # The version of Chef-DK to install.
      #
      property :version,
               String,
               default: 'latest',
               callbacks: {
                 # 'Can\'t set both a `version` and a `source`' =>
                 #   ->(_) { !%i(direct repo).include?(source) },
                 'Invalid version string' =>
                   ->(a) { ::ChefDk::Helpers.valid_version?(a) }
               }

      #
      # The Chef-DK can be installed from the :stable or :current channel.
      #
      property :channel,
               Symbol,
               coerce: proc { |v| v.to_sym },
               equal_to: %i(stable current),
               default: :stable

      #
      # Possible package sources sources include :direct download and install,
      # installation via APT/YUM/Homebrew :repo, or a specific source URL.
      #
      property :source,
               Symbol,
               coerce: proc { |v| v.to_sym },
               regex: [
                 /^direct$/,
                 /^repo$/,
                 %r{^http://},
                 %r{^https://},
                 %r{^file://}
               ],
               default: :direct # ,
               # callbacks: {
               #   'Can\'t set both a `source` and a `version`' =>
               #     ->(a) { !a.is_a?(String) || version == 'latest' }
               # }

      #
      # Return the package metadata for the current node and new_resource. Note
      # that `nil` will be returned of an override `source` was set to
      # use instead of the Omnitruck API.
      #
      # @return [Hash,NilClass] package metadata from the Omnitruck API
      #
      def package_metadata
        @package_metadata ||= ::ChefDk::Helpers.metadata_for(
          channel: new_resource.channel,
          version: new_resource.version,
          platform: node['platform'],
          platform_version: node['platform_version'],
          machine: node['kernel']['machine']
        )
      end
    end
  end
end
