# Encoding: UTF-8

node_name 'chef-dk-osx'
checksum_path '/tmp/kitchen/checksums'
file_cache_path '/tmp/kitchen/cache'
file_backup_path '/tmp/kitchen/backup'
cookbook_path %w(/tmp/kitchen/cookbooks /tmp/kitchen/site-cookbooks)
data_bag_path '/tmp/kitchen/data_bags'
environment_path '/tmp/kitchen/environments'
node_path '/tmp/kitchen/nodes'
role_path '/tmp/kitchen/roles'
client_path '/tmp/kitchen/clients'
user_path '/tmp/kitchen/users'
validation_key File.expand_path('../validation.pem', __FILE__)
client_key '/tmp/kitchen/client.pem'
chef_server_url 'http://127.0.0.1:8889'
