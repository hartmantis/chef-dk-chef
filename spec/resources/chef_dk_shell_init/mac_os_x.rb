require_relative '../chef_dk_shell_init'

shared_context 'resources::chef_dk_shell_init::mac_os_x' do
  include_context 'resources::chef_dk_shell_init'

  shared_examples_for 'any Mac OS X platform' do
    let(:root_bashrc) { '/etc/bashrc' }
    let(:user_bashrc) { '/Users/fauxhai/.profile' }
  
    it_behaves_like 'any supported platform'
  end
end
