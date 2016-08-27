# encoding: utf-8
# frozen_string_literal: true

require_relative '../linux'

describe 'resources::chef_dk_gem::mac_os_x::10_10' do
  include_context 'resources::chef_dk_gem::linux'

  let(:platform) { 'mac_os_x' }
  let(:platform_version) { '10.10' }

  it_behaves_like 'any Linux platform'
end
