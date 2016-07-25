# encoding: utf-8
# frozen_string_literal: true

include_recipe 'chef-dk'

chef_dk 'default' do
  source node['chef_dk']['source'] unless node['chef_dk']['source'].nil?
  action :remove
end
