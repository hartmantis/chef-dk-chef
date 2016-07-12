require_relative '../../chef_dk_gem'

describe 'resources::chef_dk_gem::fedora::23' do
  include_context 'resources::chef_dk_gem'

  let(:platform) { 'fedora' }
  let(:platform_version) { '23' }

  it_behaves_like 'any platform'
end
