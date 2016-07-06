require_relative '../../chef_dk'

describe 'resources::chef_dk::debian::8_4' do
  include_context 'resources::chef_dk'

  let(:platform) { 'debian' }
  let(:platform_version) { '8.4' }

  it_behaves_like 'any platform'
end
