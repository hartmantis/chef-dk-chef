require_relative '../rhel'

describe 'resources::chef_dk_shell_init::redhat::7_1' do
  include_context 'resources::chef_dk_shell_init::rhel'

  let(:platform) { 'redhat' }
  let(:platform_version) { '7.1' }

  it_behaves_like 'any RHEL platform'
end
