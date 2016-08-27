# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_shell_init'

shared_context 'resources::chef_dk_shell_init::mac_os_x' do
  include_context 'resources::chef_dk_shell_init'

  let(:root_bashrc) { '/etc/bashrc' }
  let(:user_bashrc) { '/home/fauxhai/.profile' }

  shared_examples_for 'any Mac OS X platform' do
    it_behaves_like 'any supported platform'
  end
end
