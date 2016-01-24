# Encoding: UTF-8

chef_dk_shell_init 'default' do
  user node['chef_dk']['shell_init_user']
  action :disable
end
