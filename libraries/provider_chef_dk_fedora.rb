# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Library:: provider_chef_dk_fedora
#
# Copyright 2014-2015 Jonathan Hartman
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

require 'chef/provider'
require_relative 'provider_chef_dk'
require_relative 'provider_chef_dk_rhel'

class Chef
  class Provider
    class ChefDk < Provider
      # A Chef-DK provider for Fedora, works exactly the same as RHEL.
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Fedora < ChefDk::Rhel
      end
    end
  end
end
