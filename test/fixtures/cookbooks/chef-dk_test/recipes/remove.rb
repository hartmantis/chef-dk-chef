# encoding: utf-8
# frozen_string_literal: true

include_recipe 'chef-dk'

chef_dk 'default' do
  action :remove
end
