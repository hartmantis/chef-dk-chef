# encoding: utf-8
# frozen_string_literal: true

name 'chef-dk'
maintainer 'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license 'Apache v2.0'
description 'Installs/configures the Chef-DK'
long_description 'Installs/configures the Chef-DK'
version '3.1.1'
chef_version '>= 12'

source_url 'https://github.com/roboticcheese/chef-dk-chef'
issues_url 'https://github.com/roboticcheese/chef-dk-chef/issues'

depends 'apt-chef', '~> 2.0'
depends 'yum-chef', '~> 2.0'
depends 'homebrew', '~> 2.1'
depends 'dmg', '~> 3.0'
depends 'chocolatey', '~> 1.0'

supports 'ubuntu', '>= 12.04'
supports 'debian', '>= 6.0'
%w(redhat centos scientific amazon).each do |os|
  supports       os, '>= 6.0'
end
supports 'fedora'
supports 'mac_os_x', '>= 10.8'
supports 'windows'
