# encoding: utf-8
# frozen_string_literal: true

require_relative '../../chef_dk'

describe 'resources::chef_dk::ubuntu::16_04' do
  include_context 'resources::chef_dk'

  let(:platform) { 'ubuntu' }
  let(:platform_version) { '16.04' }

  it_behaves_like 'any platform'
end
