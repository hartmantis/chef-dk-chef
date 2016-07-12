# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_shell_init_mac_os_x
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

require_relative 'resource_chef_dk_shell_init'

class Chef
  class Resource
    # An OS X implementation of the chef_dk_shell_init custom resource.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkShellInitMacOsX < ChefDkShellInit
      provides :chef_dk_shell_init, platform_family: 'mac_os_x'

      def bashrc_file
        case user
        when 'root'
          '/etc/bashrc'
        else
          ::File.join(node['etc']['passwd'][user]['dir'], '.profile')
        end
      end
    end
  end
end
