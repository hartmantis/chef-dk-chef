require_relative '../../chef_dk'

describe 'resources::chef_dk::centos::6_8' do
  include_context 'resources::chef_dk'

  let(:platform) { 'centos' }
  let(:platform_version) { '6.8' }

  it_behaves_like 'any platform'
end
