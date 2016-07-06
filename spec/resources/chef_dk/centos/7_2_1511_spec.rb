require_relative '../../chef_dk'

describe 'resources::chef_dk::centos::7_2_1511' do
  include_context 'resources::chef_dk'

  let(:platform) { 'centos' }
  let(:platform_version) { '7.2.1511' }

  it_behaves_like 'any platform'
end
