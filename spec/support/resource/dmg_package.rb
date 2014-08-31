# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Resource:: dmg_package
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

class Chef
  class Resource
    # A fake dmg_package resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class DmgPackage < Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :dmg_package
        @action = :install
        @allowed_actions = [:install, :remove]
      end

      def app(arg = nil)
        set_or_return(:app, arg, kind_of: String)
      end

      def source(arg = nil)
        set_or_return(:source, arg, kind_of: String)
      end

      def type(arg = nil)
        set_or_return(:type, arg, kind_of: String)
      end
    end
  end
end
