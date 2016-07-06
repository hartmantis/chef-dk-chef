require_relative '../../chef_dk'

describe 'resources::chef_dk::redhat::7_1' do
  include_context 'resources::chef_dk'

  let(:platform) { 'redhat' }
  let(:platform_version) { '7.1' }

  it_behaves_like 'any platform'
end
