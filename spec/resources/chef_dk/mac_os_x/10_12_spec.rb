# encoding: utf-8
# frozen_string_literal: true

require_relative '../../chef_dk'

describe 'resources::chef_dk::mac_os_x::10_12' do
  include_context 'resources::chef_dk'

  let(:platform) { 'mac_os_x' }
  let(:platform_version) { '10.12' }

  it_behaves_like 'any platform'
end
