# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk
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

require 'chef/provider/lwrp_base'
require 'chef/util/file_edit'

class Chef
  class Provider
    # A Chef provider for the Chef-DK packages
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDk < LWRPBase
      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Install the ChefDK.
      #
      action :install do
        chef_gem 'omnijack' do
          version '~> 1.0'
          compile_time true
          not_if { new_resource.package_url }
        end
        install!
        bf = bashrc_file unless node['platform_family'] == 'windows'
        ruby_block 'Create Chef global shell-init' do
          block do
            matcher = /^eval "\$\(chef shell-init bash\)"$/
            line = 'eval "$(chef shell-init bash)"'
            f = Chef::Util::FileEdit.new(bf)
            f.insert_line_if_no_match(matcher, line)
            f.write_file
          end
          only_if do
            new_resource.global_shell_init && \
              node['platform_family'] != 'windows'
          end
        end
      end

      #
      # Remove the ChefDK.
      #
      action :remove do
        bf = bashrc_file unless node['platform_family'] == 'windows'
        ruby_block 'Delete Chef global shell-init' do
          block do
            matcher = /^eval "\$\(chef shell-init bash\)"$/
            f = Chef::Util::FileEdit.new(bf)
            f.search_file_delete_line(matcher)
            f.write_file
          end
          only_if { node['platform_family'] != 'windows' }
        end
        remove!
      end

      private

      # Some methods have to be provided by the sub-classes
      [:bashrc_file, :install!, :remove!].each do |method|
        define_method(method) do
          fail(NotImplementedError,
               "`#{method}` method must be implemented for `#{self.class}`")
        end
      end

      #
      # Return the package download source, either from Omnitruck metadata or
      # a :package_url property.
      #
      # @return [String] a download URL/path
      #
      def package_source
        new_resource.package_url || metadata.url
      end

      #
      # Get the package metadata.
      #
      # @return [Hash] package metadata from the omnitruck API
      #
      def metadata
        @metadata ||= begin
          require 'omnijack'
          m = Omnijack::Project::ChefDk.new(metadata_params).metadata
          m.yolo && Chef::Log.warn('Using a ChefDk package not officially ' \
                                   'supported on this platform')
          m
        end
      end

      #
      # Construct the hash of parameters for Omnijack to get the right metadata
      #
      # @return [Hash] properties required to fetch package metadata
      #
      def metadata_params
        { platform: node['platform'],
          platform_version: node['platform_version'],
          machine_arch: node['kernel']['machine'],
          version: new_resource.version,
          prerelease: new_resource.prerelease,
          nightlies: new_resource.nightlies }
      end
    end
  end
end
