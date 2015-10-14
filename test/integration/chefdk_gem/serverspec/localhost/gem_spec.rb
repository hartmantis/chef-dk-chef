# Encoding: UTF-8

require_relative '../spec_helper'

describe 'Chef-DK Gem' do
  describe file('/root/.chefdk/gem/ruby/2.1.0/gems/knife-supermarket-0.2.1'),
           if: %w(ubuntu debian redhat fedora).include?(os[:family]) do
    it { should exist }
  end
end
