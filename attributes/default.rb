# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Attributes:: default
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

default['chef_dk']['version'] = 'latest'
default['chef_dk']['package_url'] = nil
default['chef_dk']['global_shell_init'] = false
default['chef_dk']['wrappers'] = false
default['chef_dk']['wrapper_path'] = '/usr/local/bin'
