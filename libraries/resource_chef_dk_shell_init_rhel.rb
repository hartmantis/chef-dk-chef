# encoding: utf-8
# frozen_string_literal: true

#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_shell_init_rhel
#
# Copyright 2014-2017, Jonathan Hartman
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

require_relative 'resource_chef_dk_shell_init'

class Chef
  class Resource
    # A RHEL(-alike) implementation of the chef_dk_shell_init custom resource.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkShellInitRhel < ChefDkShellInit
      provides :chef_dk_shell_init, platform_family: 'rhel'
      provides :chef_dk_shell_init, platform_family: 'fedora'

      def bashrc_file
        case user
        when 'root'
          '/etc/bashrc'
        else
          ::File.join(node['etc']['passwd'][user]['dir'], '.bashrc')
        end
      end
    end
  end
end
