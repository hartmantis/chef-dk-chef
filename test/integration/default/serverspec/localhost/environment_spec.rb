# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'

describe 'chef-dk::default::environment' do
  shared_examples_for 'file with chef shell-init' do
    it 'contains the chef shell-init command' do
      matcher = /^eval "\$\(chef shell-init bash\)"$/
      expect(subject.content).to match(matcher)
    end
  end

  describe file('/etc/bashrc'),
           if: %w(darwin redhat fedora).include?(os[:family]) do
    it_behaves_like 'file with chef shell-init'
  end

  describe file('/etc/bash.bashrc'),
           if: %w(ubuntu debian).include?(os[:family]) do
    it_behaves_like 'file with chef shell-init'
  end

  describe command('/opt/chefdk/embedded/bin/gem list cabin'),
           if: os[:family] != 'windows' do
    it 'shows the requested gem is installed' do
      expect(subject.stdout).to match(/^cabin \(/)
    end
  end

  describe file(
    '~/AppData/Local/chefdk/gem/ruby/2.3.0/bin/rubygems-cabin-test'
  ), if: os[:family] == 'windows'  do
    it 'shows the requested gem is installed' do
      expect(subject).to exist
    end
  end
end
