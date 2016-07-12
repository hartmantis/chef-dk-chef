require_relative '../../chef_dk_gem'

describe 'resources::chef_dk_gem::windows::10' do
  include_context 'resources::chef_dk_gem'

  let(:platform) { 'windows' }
  let(:platform_version) { '10' }

  it_behaves_like 'any platform'
end
