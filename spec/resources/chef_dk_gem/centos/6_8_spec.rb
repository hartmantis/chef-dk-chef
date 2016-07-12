require_relative '../../chef_dk_gem'

describe 'resources::chef_dk_gem::centos::6_8' do
  include_context 'resources::chef_dk_gem'

  let(:platform) { 'centos' }
  let(:platform_version) { '6.8' }

  it_behaves_like 'any platform'
end
