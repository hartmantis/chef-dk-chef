# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk
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

class Chef
  class Resource
    # A parent Chef resource that wraps up our children.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDk < Resource
      provides :chef_dk

      default_action :create

      #
      # Property for a list of gems to install inside Chef-DK's included Ruby.
      #
      property :gems, Array, default: []

      #
      # Property for a list of users for whom to set Chef-DK's included Ruby
      # environment as the default.
      #
      property :shell_users, Array, default: []

      #
      # Install the ChefDK and configure shell init as appropriate
      #
      action :create do
        chef_dk_app new_resource.name
        new_resource.gems.each { |g| chef_dk_gem(g) }
        new_resource.shell_users.each { |u| chef_dk_shell_init(u) }
      end

      #
      # Remove the ChefDK.
      #
      action :remove do
        chef_dk_shell_init new_resource.name do
          action :disable
        end
        chef_dk_app(new_resource.name) { action :remove }
      end
    end
  end
end
