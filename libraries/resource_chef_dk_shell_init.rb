# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: resource_chef_dk_shell_init
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
require 'chef/util/file_edit'

class Chef
  class Resource
    # A Chef custom resource for enabling or disabling Chef-DK's shell-init
    # mode.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ChefDkShellInit < Resource
      #
      # Property for the user whose bashrc should be modified. If set to 'root',
      # it will be set globally.
      #
      property :user, String, name_property: true

      default_action :enable

      action :enable do
        file bashrc_file do
          content lazy {
            txt = 'eval "$(chef shell-init bash)"'
            lines = ::File.read(bashrc_file).split("\n")
            lines << txt unless lines.include?(txt)
            lines.join("\n")
          }
        end
      end

      action :disable do
        file bashrc_file do
          content lazy {
            lines = ::File.read(bashrc_file).split("\n")
            lines.delete('eval "$(chef shell-init bash)"')
            lines.join("\n")
          }
          only_if { ::File.exist?(bashrc_file) }
        end
      end

      def bashrc_file
        raise(NotImplementedError,
              "`bashrc_file` must be implemented for `#{self.class}`")
      end
    end
  end
end
