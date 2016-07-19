# Encoding: UTF-8

require_relative '../spec_helper'

describe 'chef-dk::default::environment' do
  shared_examples_for 'file with chef shell-init' do
    it 'contains the chef shell-init command' do
      matcher = /^eval "\$\(chef shell-init bash\)"$/
      expect(subject.content).to_not match(matcher)
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

  describe command('/opt/chefdk/embedded/bin/gem list omnijack') do
    it 'show the requested gem is installed' do
      expect(subject.stdout).to match(/^omnijack \(/)
    end
  end
end
