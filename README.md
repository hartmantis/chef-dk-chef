Chef-DK Cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/chef-dk.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/chef-dk-chef.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/chef-dk-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/chef-dk-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/chef-dk
[travis]: https://travis-ci.org/RoboticCheese/chef-dk-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/chef-dk-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/chef-dk-chef

A cookbook for installing the Chef Development Kit.

Requirements
============

As of version 0.3.5, Chef-DK packages are available for RHEL/CentOS/etc. 6,
Ubuntu 12.04/13.10, Debian 6/7, OS X 10.8/10.9/10.10, and Windows 7/8/2008/2012.
Each of these platforms is supported by this cookbook.

In some cases, platforms that aren't officially supported by Chef-DK may still
function. For example, this cookbook could be used to install the Ubuntu package
onto a 14.04 system. YMMV.

Prior to Chef 11.12.0, the core did not offer the `windows_package` resource
that is used for installation under Windows. _This cookbook will not run on
Windows under earlier versions of Chef._

This cookbook consumes the
[dmg cookbook](https://supermarket.chef.io/cookbooks/dmg) in order to
support OS X installs. That cookbook's limitations, such as the inability
to upgrade or uninstall packages, are thus present in the OS X implementation
here.

Package download information is obtained from Chef's
[Omnitruck API](https://github.com/opscode/opscode-omnitruck) using the
[Omnijack Gem](https://github.com/RoboticCheese/omnijack-ruby) that is
installed at runtime.

Usage
=====

This cookbook can be implemented either by calling its resource directly, or
adding the recipe that wraps it to your run\_list.

Recipes
=======

***default***

Calls the `chef_dk` resource to do a package install.

Attributes
==========

***default***

Attributes are provided to allow overriding of the package version or URL the
default recipe installs:

    default['chef_dk']['version'] = 'latest'
    default['chef_dk']['package_url'] = nil
    default['chef_dk']['global_shell_init'] = false

Resources
=========

***chef_dk***

Wraps the fetching of the package file from S3 and the package installation
into a single resource:

Syntax:

    chef_dk 'my_chef_dk' do
        version '1.2.3-4'
        global_shell_init true
        action :install
    end

Actions:

| Action     | Description                   |
|------------|-------------------------------|
| `:install` | Default; installs the Chef-DK |
| `:remove`  | Uninstalls the Chef-DK        |

Attributes:

| Attribute           | Default    | Description                               |
|---------------------|------------|-------------------------------------------|
| `version`           | `'latest'` | Install a specific version\*              |
| `prerelease`        | `false`    | Enable installation of prerelease builds  |
| `nightlies`         | `false`    | Enable installation of nightly builds     |
| `package_url`       | `nil`      | DL from a specific URL\*                  |
| `global_shell_init` | `false`    | Set ChefDK as the global default Ruby\*\* |

_\* A `version` and `package_url` cannot be used together_

_\*\* The global Ruby env is set by a bashrc, so not compatible with Windows_

Providers
=========

This cookbook includes a provider for each of its supported platform families.
By default, the `chef_dk` resource will determine a provider to used based on
the platform on which Chef is running.

***Chef::Provider::ChefDk***

A generic provider of all non-platform-specific functionality.

***Chef::Provider::ChefDk::Debian***

Provides the Ubuntu platform support.

***Chef::Provider::ChefDk::MacOsX***

Provides the Mac OS X platform support.

***Chef::Provider::ChefDk::Rhel***

Provides the RHEL and RHELalike platform support.

***Chef::Provider::ChefDk::Windows***

Provides the Windows platform support.

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run style checks and RSpec tests (`bundle exec rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@p4nt5.com>

Copyright 2014-2015, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
