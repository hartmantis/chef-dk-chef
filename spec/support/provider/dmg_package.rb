# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Provider
    # A fake dmg_package provider
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class DmgPackage < Provider::LWRPBase
    end
  end
end
