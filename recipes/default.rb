# Encoding: UTF-8
#
# Cookbook Name:: chef-dk
# Recipe:: default
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
# limitations under the  License.
#

attrs = node['chef_dk']

chef_dk 'default' do
  version attrs['version'] unless attrs['version'].nil?
  channel attrs['channel'] unless attrs['channel'].nil?
  source attrs['source'] unless attrs['source'].nil?
  checksum attrs['checksum'] unless attrs['checksum'].nil?
  gems attrs['gems'] unless attrs['gems'].nil?
  shell_users attrs['shell_users'] unless attrs['shell_users'].nil?
end
