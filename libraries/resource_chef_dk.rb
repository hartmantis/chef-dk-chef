# encoding: utf-8
# frozen_string_literal: true
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
require_relative 'resource_chef_dk_app'

class Chef
  class Resource
    # A parent Chef resource that wraps up our children.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDk < Resource
      provides :chef_dk

      default_action :create

      #
      # Accept all the chef_dk_app resource's properties so they can be passed
      # on to the embedded chef_dk_app resource.
      #
      Chef::Resource::ChefDkApp.state_properties.each do |prop|
        property prop.name, prop.options
      end

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
        chef_dk_app new_resource.name do
          Chef::Resource::ChefDkApp.state_properties.each do |prop|
            unless new_resource.send(prop.name).nil?
              send(prop.name, new_resource.send(prop.name))
            end
          end
          checksum new_resource.checksum unless new_resource.checksum.nil?
        end
        new_resource.gems.each { |g| chef_dk_gem(g) }
        new_resource.shell_users.each { |u| chef_dk_shell_init(u) }
      end

      #
      # Remove the ChefDK.
      #
      action :remove do
        unless node['platform_family'] == 'windows'
          node['etc']['passwd'].keys.each do |u|
            chef_dk_shell_init(u) { action :disable }
          end
        end
        chef_dk_app(new_resource.name) { action :remove }
      end
    end
  end
end
