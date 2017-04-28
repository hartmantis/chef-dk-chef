# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::repo::package' do
  describe file('/usr/local/bin/chef'), if: os[:family] == 'darwin' do
    it 'exists' do
      expect(subject).to be_file
    end
  end

  describe command('chocolatey list chefdk'), if: os[:family] == 'windows' do
    it 'indicates Chef-DK is installed' do
      expect(subject.exit_status).to eq(0)
    end
  end

  describe file('/etc/apt/sources.list.d/chef-stable.list'),
           if: %w[ubuntu debian].include?(os[:family]) do
    it 'exists' do
      expect(subject).to be_file
    end
  end

  describe file('/etc/yum.repos.d/chef-stable.repo'),
           if: %w[redhat fedora].include?(os[:family]) do
    it 'exists' do
      expect(subject).to be_file
    end
  end

  describe package('com.getchef.pkg.chefdk'), if: os[:family] == 'darwin' do
    it 'is installed' do
      expect(subject).to be_installed.by(:pkgutil)
    end
  end

  # On Windows, the package name changes to reflect each ChefDK version
  describe package('Chef Development Kit v*'), if: os[:family] == 'windows' do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe package('chefdk'),
           if: %w[ubuntu debian redhat fedora].include?(os[:family]) do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end
end
