# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::install_from_specific_url::package' do
  describe package('chefdk') do
    it 'is installed with the right version' do
      expect(subject).to be_installed.with_version('0.14.25-1')
    end
  end
end
