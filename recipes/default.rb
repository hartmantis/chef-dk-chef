# encoding: utf-8
# frozen_string_literal: true
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
  Chef::Resource::ChefDkApp.state_properties.each do |prop|
    send(prop.name, attrs[prop.name]) unless attrs[prop.name].nil?
  end
  gems attrs['gems'] unless attrs['gems'].nil?
  shell_users attrs['shell_users'] unless attrs['shell_users'].nil?
end
