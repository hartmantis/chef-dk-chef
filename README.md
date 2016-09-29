Chef-DK Cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/chef-dk.svg)][cookbook]
[![OS X Build Status](https://img.shields.io/travis/RoboticCheese/chef-dk-chef.svg)][travis]
[![Windows Build Status](https://img.shields.io/appveyor/ci/RoboticCheese/chef-dk-chef.svg)][appveyor]
[![Linux Build Status](https://img.shields.io/circleci/project/RoboticCheese/chef-dk-chef.svg)][circle]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/chef-dk-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/chef-dk-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/chef-dk
[travis]: https://travis-ci.org/RoboticCheese/chef-dk-chef
[appveyor]: https://ci.appveyor.com/project/RoboticCheese/chef-dk-chef
[circle]: https://circleci.com/gh/RoboticCheese/chef-dk-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/chef-dk-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/chef-dk-chef

A cookbook for installing the Chef Development Kit.

Requirements
============

This cookbook attempts to support all platforms the Chef-DK is available for.
A complete list can be found on the
[Chef-DK download site](https://downloads.chef.io/chef-dk/).

As of v4.0, this cookbook requires Chef 12.5+, or Chef 12.x combined with the
[compat_resource](https://supermarket.chef.io/cookbooks/compat_resource)
cookbook.

Usage
=====

Either set the desired attributes and add the default recipe to your run list
or create a recipe of your own that uses the included custom resources.

Recipes
=======

***default***

Performs an attribute-based installation of the Chef-DK.

Attributes
==========

***default***

    default['chef_dk']['version'] = nil

If desired, a specific version of the Chef-DK can be installed rather than the
most recent.

    default['chef_dk']['channel'] = nil

The package channel to install Chef-DK from (`:stable` or `:current`).

    default['chef_dk']['source'] = nil

A default install will query Chef's Omnitruck API and download the package file
directly from wherever it points. Optional install methods are via a package
`:repo` (APT, YUM, Homebrew, or Chocolatey) or a specific download URL.

    default['chef_dk']['checksum'] = nil

The optional checksum of the package if a custom source is provided.

    default['chef_dk']['gems'] = nil

This can be overridden to install a desired list of gems in Chef-DK's embedded
Ruby environment.

    default['chef_dk']['shell_users'] = nil

A list of users can be provided for whom to make Chef's Ruby environment the
default.

Resources
=========

***chef_dk***

Wraps the other resources into a single parent.

Syntax:

    chef_dk 'default' do
      version '1.2.3'
      source :repo
      global_shell_init true
      action :create
    end

Properties:

| Property    | Default   | Description                                      |
|-------------|-----------|--------------------------------------------------|
| version     | `nil`     | Install a specific version                       |
| channel     | `nil`     | Install from a specific channel                  |
| source      | `nil`     | Install via a specific method or URL             |
| checksum    | `nil`     | Checksum of a custom source package file         |
| gems        | `[]`      | Gems to install in Chef-DK's Ruby                |
| shell_users | `[]`      | Users for whom to make Chef-DK's Ruby default \* |
| action      | `:create` | The action to perform                            |

_\* This setting uses bashrc and profile files, so is not compatible with
Windows_

Actions:

| Action     | Description                                  |
|------------|----------------------------------------------|
| `:create ` | Default; installs and configures the Chef-DK |
| `:remove`  | Uninstalls the Chef-DK                       |

***chef_dk_app***

Manages installation of Chef-DK.

Syntax:

    chef_dk_app 'default' do
      version '1.2.3'
      channel :current
      source :repo
      action :install
    end

Properties:

| Property | Default    | Description                                         |
|----------|------------|-----------------------------------------------------|
| version  | `'latest'` | Optionally install a specific version               |
| channel  | `:stable`  | Use the `:stable` or `:current` channel             |
| source   | `:direct`  | Install vi Omnitruck (`:direct`), a `:repo`, or URL |
| checksum | `nil`      | Optional checksum of a custom source package        |
| action   | `:install` | The action to perform                               |

Actions:

| Action     | Description                   
|------------|---------------------------------------------|
| `:install` | Default; installs the Chef-DK               |
| `:upgrade` | Install or upgrade to the latest Chef-DK \* |
| `:remove`  | Uninstalls the Chef-DK                      |

\* The `:upgrade` action suports the `:direct` and `:repo` sources only. It
will always install the latest version. The use of a `version` property with it
is not supported.

***chef_dk_gem***

Manages gems inside Chef-DK's embedded Ruby environment.

Syntax:

    chef_dk_gem 'rest-client' do
      action :install
    end

Properties:

| Property | Default       | Description           |
|----------|---------------|-----------------------|
| \*       | See note      | See note              |

Actions:

| Action | Description |
|--------|-------------|
| \*     | See note    |

\* Properties and actions for the chef_dk_gem resource are the same as for
Chef's built-in [gem_package](https://docs.chef.io/resource_gem_package.html)
resource.

***chef_dk_shell_init***

Set Chef-DK's integrated Ruby environment as the default for a user.

Syntax:

    chef_dk_shell_init 'myself' do
      action :enable
    end

Properties:

| Property | Default       | Description           |
|----------|---------------|-----------------------|
| user     | Resource name | The user to configure |
| action   | `:enable`     | The action to perform |

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:enable`  | Add a bashrc entry for the user |
| `:disable` | Remove the bashrc entry         |

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

Copyright 2014-2016, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
