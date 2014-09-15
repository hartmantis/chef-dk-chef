#!/bin/sh
BUSSER_ROOT="/tmp/busser"
GEM_HOME="/tmp/busser/gems"
GEM_PATH="/tmp/busser/gems"
GEM_CACHE="/tmp/busser/gems/cache"
export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE
/opt/chef/embedded/bin/gem install serverspec --pre
