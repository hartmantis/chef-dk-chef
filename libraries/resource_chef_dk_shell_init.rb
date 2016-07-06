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
      # Property to allow specifying a single user whose bashrc should be
      # modified instead of the global one.
      #
      property :user, [String, nil], default: nil

      default_action :enable

      action :enable do
        matcher = /^eval "\$\(chef shell-init bash\)"$/
        line = 'eval "$(chef shell-init bash)"'
        f = Chef::Util::FileEdit.new(bashrc_file)
        puts "F: #{f}"
        puts "F: #{f.insert_line_if_no_match(matcher, line)}"
        if f.insert_line_if_no_match(matcher, line)
          Chef::Log.debug("Writing '#{line}' to file '#{bashrc_file}'")
          f.write_file
          updated_by_last_action(true)
        end
      end

      action :disable do
        matcher = /^eval "\$\(chef shell-init bash\)"$/
        f = Chef::Util::FileEdit.new(bashrc_file)
        if f.search_file_delete_line(matcher)
          line = 'eval "$(chef shell-init bash)"'
          Chef::Log.debug("Deleting '#{line}' from file '#{bashrc_file}'")
          f.write_file
          updated_by_last_action(true)
        end
      end

      def bashrc_file
        raise(NotImplementedError,
              "`bashrc_file` must be implemented for `#{self.class}`")
      end
    end
  end
end
