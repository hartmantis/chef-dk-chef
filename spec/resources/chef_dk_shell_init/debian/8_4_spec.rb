# encoding: utf-8
# frozen_string_literal: true

require_relative '../debian'

describe 'resources::chef_dk_shell_init::debian::8_4' do
  include_context 'resources::chef_dk_shell_init::debian'

  let(:platform) { 'debian' }
  let(:platform_version) { '8.4' }

  it_behaves_like 'any Debian platform'
end
