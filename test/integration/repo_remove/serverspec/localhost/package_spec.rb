# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::repo_remove::package' do
  describe file('/usr/local/bin/chef'), if: os[:family] == 'darwin' do
    it 'does not exist' do
      expect(subject).to_not exist
    end
  end

  describe command('chocolatey list chefdk'), if: os[:family] == 'windows' do
    it 'indicates Chef-DK is not installed' do
      expect(subject.exit_status).to eq(1)
    end
  end

  describe package('com.getchef.pkg.chefdk'), if: os[:family] == 'darwin' do
    it 'is not installed' do
      expect(subject).to_not be_installed.by(:pkgutil)
    end
  end

  # On Windows, the package name changes to reflect each ChefDK version
  describe package('Chef Development Kit v*'), if: os[:family] == 'windows' do
    it 'is not installed' do
      expect(subject).to_not be_installed
    end
  end

  describe package('chefdk'),
           if: %w(ubuntu debian redhat fedora).include?(os[:family]) do
    it 'is not installed' do
      expect(subject).to_not be_installed
    end
  end
end
