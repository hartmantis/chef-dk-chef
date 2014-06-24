Chef-DK Cookbook
================
[![Cookbook Version](http://img.shields.io/cookbook/v/chef-dk.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/chef-dk-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/chef-dk
[travis]: http://travis-ci.org/RoboticCheese/chef-dk-chef

A cookbook for installing the Chef Development Kit.

Requirements
============

A RHEL/CentOS/etc. 6, Ubuntu 12.04, or Ubuntu 13.10 node (while there are .dmg
packages for OS X, there is not a Chef resource to automate installation of
them).

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

An attribute is provided to allow overriding of the package version the default
recipe installs:

    default['chef_dk']['version'] = 'latest'

Resources
=========

***chef_dk***

Wraps the fetching of the package file from S3 and the package installation
into a single resource:

    chef_dk '<A RESOURCE NAME>' do
        version '<AN OPTIONAL VERSION OVERRIDE (DEFAULT IS 'latest')>'
        action <:install|:uninstall (DEFAULT IS :install)>
    end

License & Authors
-----------------
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
