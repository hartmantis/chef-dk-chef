require_relative '../linux'

describe 'resources::chef_dk_gem::fedora::23' do
  include_context 'resources::chef_dk_gem::linux'

  let(:platform) { 'fedora' }
  let(:platform_version) { '23' }

  it_behaves_like 'any Linux platform'
end
