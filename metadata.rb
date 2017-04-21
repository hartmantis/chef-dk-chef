# encoding: utf-8
# frozen_string_literal: true

name 'chef-dk'
maintainer 'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license 'Apache-2.0'
description 'Installs/configures the Chef-DK'
long_description 'Installs/configures the Chef-DK'
version '3.1.1'
chef_version '>= 12'

source_url 'https://github.com/roboticcheese/chef-dk-chef'
issues_url 'https://github.com/roboticcheese/chef-dk-chef/issues'

depends 'apt-chef', '< 3.0'
depends 'yum-chef', '< 4.0'
depends 'homebrew', '< 5.0'
depends 'dmg', '< 4'
depends 'chocolatey', '< 2'

supports 'ubuntu'
supports 'debian'
%w[redhat centos scientific amazon].each do |os|
  supports os
end
supports 'fedora'
supports 'mac_os_x'
supports 'windows'
