require_relative '../chef_dk_shell_init'

shared_context 'resources::chef_dk_shell_init::rhel' do
  include_context 'resources::chef_dk_shell_init'

  shared_examples_for 'any RHEL platform' do
    let(:root_bashrc) { '/etc/bashrc' }
    let(:user_bashrc) { '/home/fauxhai/.bashrc' }

    it_behaves_like 'any supported platform'
  end
end
