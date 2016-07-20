# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::install_from_specific_url::package' do
  describe package('chefdk') do
    it 'is installed with the right version' do
      expect(subject).to be_installed.with_version('0.3.4-1')
    end
  end

  describe command('/opt/chef/embedded/bin/gem list omnijack') do
    it 'does not list Omnijack as installed' do
      expect(subject.stdout).not_to match(/^omnijack /)
    end
  end
end
