# encoding: utf-8
# frozen_string_literal: true
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
               [String, FalseClass],
               default: 'latest',
               callbacks: {
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
               regex: [/^direct$/, /^repo$/, %r{^https?://}, %r{^file://}],
               default: :direct

      #
      # Accept an optional property for the checksum of a package file
      # downloaded from a custom source.
      #
      property :checksum, String

      #
      # Keep a property to track the installed state of the Chef-DK.
      #
      property :installed, [TrueClass, FalseClass]

      #
      # The current value is determined by calling the `installed_version`
      # method, which must be defined in each sub-provider, depending on the
      # platform.
      #
      load_current_value do
        version(installed_version)
        installed(version == false ? false : true)
      end

      #
      # Install the Chef-DK in one of three ways:
      #
      # * Direct - Get a download URL from the Omnitruck API then download and
      #   install that file. If a version property is specified, install that
      #   version. If no version property is specified, do nothing if any
      #   version is already installed.
      # * Repo - Configure a package repo (APT, YUM, Homebrew, Chocolatey) and
      #   install the package from there.
      # * Custom - Download a package from a specified custom URL.
      #
      action :install do
        new_resource.installed(true)

        case new_resource.source
        when :direct
          converge_if_changed(:installed) { install_direct! }
        when :repo
          install_repo!
        else
          install_custom!
        end
      end

      #
      # Install or upgrade to the latest version of the Chef-DK in one of three
      # ways:
      #
      # * Direct - Install or upgrade to Omnitruck's latest advertised version.
      # * Repo - Send an upgrade action to the underlying package resource.
      # * Custom - Raise an error, the :upgrade action is not supported for
      #   custom installs.
      #
      action :upgrade do
        new_resource.installed(true)
        new_resource.version('latest')

        case new_resource.source
        when :direct
          converge_if_changed(:installed, :version) { upgrade_direct! }
        when :repo
          upgrade_repo!
        else
          raise(Chef::Exceptions::UnsupportedAction,
                'Custom source installs do not support the :upgrade action')
        end
      end

      #
      # Remove any installed Chef-DK package. The remove action is the same,
      # regardless of the package's original install method.
      #
      action :remove do
        new_resource.installed(false)

        case new_resource.source
        when :direct
          remove_direct!
        when :repo
          remove_repo!
        else
          remove_custom!
        end
      end

      #
      # The specific methods to install, upgrade, or remove the Chef-DK app
      # must be defined for each sub-provider
      #
      action_class.class_eval do
        %i(
          install_direct!
          install_repo!
          install_custom!
          upgrade_direct!
          upgrade_repo!
          remove_direct!
          remove_repo!
          remove_custom!
        ).each do |m|
          define_method(m) do
            raise(NotImplementedError,
                  "The `#{m}` method must be implemented for the " \
                  "`#{self.class}` provider")
          end
        end
      end

      #
      # Construct a download path in Chef's cache directory for either direct
      # or custom package downloads. This can be useful for package resources
      # that won't accept a remote URL as their source.
      #
      # @return [String] a package download path
      #
      def local_path
        src = if %i(direct repo).include?(new_resource.source)
                package_metadata[:url]
              else
                new_resource.source.to_s
              end
        ::File.join(Chef::Config[:file_cache_path], ::File.basename(src))
      end

      #
      # Return the package metadata for the current node and new_resource.
      # Note that `nil` will be returned of an override `source` was set to
      # use instead of the Omnitruck API.
      #
      # @return [Hash,NilClass] package metadata from the Omnitruck API
      #
      def package_metadata
        @package_metadata ||= ::ChefDk::Helpers.metadata_for(
          channel: channel,
          version: version,
          platform: node['platform'],
          platform_version: node['platform_version'],
          machine: node['kernel']['machine']
        )
      end

      #
      # The `installed_version` method much be defined by each sub-provider.
      #
      # @return [String, FalseClass] "major.minor.patch", "latest", or false
      #
      # @raise [NotImplementedError] if not defined for this provider
      #
      def installed_version
        raise(NotImplementedError,
              'The `installed_version` method must be implemented for the ' \
              "`#{self.class}` provider")
      end
    end
  end
end
