Chef-DK Cookbook
================
[![Cookbook Version](http://img.shields.io/cookbook/v/chef-dk.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/chef-dk-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/chef-dk
[travis]: http://travis-ci.org/RoboticCheese/chef-dk-chef

A cookbook for installing the Chef Development Kit.

Requirements
============

A RHEL/CentOS/etc. 6, Ubuntu 12.04/13.10, or OS X 10.9.x node.

This cookbook consumes the
[dmg cookbook](http://supermarket.getchef.com/cookbooks/dmg) in order to
support OS X installs.

Usage
=====

This cookbook can be implemented either by calling its resource directly, or
adding the recipe that wraps it to your run_list.

Recipes
=======

***default***

Calls the `chef_dk` resource to do a package install

Attributes
==========

***default***

Attributes are provided to allow overriding of the package version or URL the
default recipe installs:

    default['chef_dk']['version'] = 'latest'
    default['chef_dk']['package_url'] = nil

Resources
=========

***chef_dk***

Wraps the fetching of the package file from S3 and the package installation
into a single resource:

    chef_dk '<A RESOURCE NAME>' do
        version '1.2.3-4'
        package_url 'http://here.is.the/package/url'
        action :install
    end

* `version` - An optional version to install (default is `'latest'`)
* `package_url` - An optional override package URL (default is determined at
  run time based on the OS and desired version)
* `action` - Action to perform (default is `:install`, also supports
  `:uninstall`)

_Note: A `version` and `package_url` cannot be used together_

To Do
=====

* TODO: Refactor the `platform` and `platform_version` logic to attempt
  installation of the Ubuntu and OS X packages in other versions of those OSes,
  maybe split the package types into multiple providers
* TODO: It's a huge PitA to not have automated testing for OS X and Windows :(

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

Copyright 2014, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
