# frozen_string_literal: true
require_relative '../../chef_dk'

describe 'resources::chef_dk::windows::10' do
  include_context 'resources::chef_dk'

  let(:platform) { 'windows' }
  let(:platform_version) { '10' }

  it_behaves_like 'any platform'
end
