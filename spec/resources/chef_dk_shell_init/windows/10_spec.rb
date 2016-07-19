require_relative '../windows'

describe 'resources::chef_dk_shell_init::windows::10' do
  include_context 'resources::chef_dk_shell_init::windows'

  let(:platform) { 'windows' }
  let(:platform_version) { '10' }
  let(:name) { 'admin' }

  it_behaves_like 'any Windows platform'
end
