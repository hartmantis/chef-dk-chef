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
require_relative '../provider/chef_dk'

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
        @provider = Provider::ChefDk

        @action = :install
        @version = 'latest'
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
        set_or_return(:version, arg, kind_of: String)
      end
    end
  end
end
