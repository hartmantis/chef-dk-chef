# Encoding: UTF-8

include_recipe 'chef-dk'

chef_dk 'default' do
  action :remove
end
