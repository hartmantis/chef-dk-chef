# encoding: utf-8
# frozen_string_literal: true

unless node['platform_family'] == 'windows'
  default['chef_dk']['shell_users'] = %w[root]
end

default['chef_dk']['gems'] = %w[cabin]
