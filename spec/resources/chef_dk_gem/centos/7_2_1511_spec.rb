require_relative '../../chef_dk_gem'

describe 'resources::chef_dk_gem::centos::7_2_1511' do
  include_context 'resources::chef_dk_gem'

  let(:platform) { 'centos' }
  let(:platform_version) { '7.2.1511' }

  it_behaves_like 'any platform'
end
