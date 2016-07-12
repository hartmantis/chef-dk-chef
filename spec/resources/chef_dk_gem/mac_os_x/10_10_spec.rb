require_relative '../../chef_dk_gem'

describe 'resources::chef_dk_gem::mac_os_x::10_10' do
  include_context 'resources::chef_dk_gem'

  let(:platform) { 'mac_os_x' }
  let(:platform_version) { '10.10' }

  it_behaves_like 'any platform'
end
