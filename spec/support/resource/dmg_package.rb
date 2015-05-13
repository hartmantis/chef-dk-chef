# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Resource
    # A fake dmg_package resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class DmgPackage < Resource::LWRPBase
      self.resource_name = :dmg_package
      actions [:install, :remove]
      default_action :install
      attribute :app, kind_of: String
      attribute :source, kind_of: String
      attribute :type, kind_of: String
    end
  end
end
