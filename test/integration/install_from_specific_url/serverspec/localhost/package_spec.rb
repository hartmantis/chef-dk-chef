# Encoding: UTF-8

require_relative '../spec_helper'

describe 'Chef-DK package' do
  describe package('chefdk') do
    it 'is installed with the right version' do
      expect(subject).to be_installed.with_version('0.3.4-1')
    end
  end
end
