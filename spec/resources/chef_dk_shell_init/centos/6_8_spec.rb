require_relative '../rhel'

describe 'resources::chef_dk_shell_init::centos::6_8' do
  include_context 'resources::chef_dk_shell_init::rhel'

  let(:platform) { 'centos' }
  let(:platform_version) { '6.8' }

  it_behaves_like 'any RHEL platform'
end
