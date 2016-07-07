require_relative '../debian'

describe 'resources::chef_dk_shell_init::ubuntu::16_04' do
  include_context 'resources::chef_dk_shell_init::debian'

  let(:platform) { 'ubuntu' }
  let(:platform_version) { '16.04' }

  it_behaves_like 'any Debian platform'
end
