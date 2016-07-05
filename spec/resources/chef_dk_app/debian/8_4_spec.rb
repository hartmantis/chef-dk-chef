require_relative '../debian'

describe 'resources::chef_dk_app::debian::8_4' do
  include_context 'resources::chef_dk_app::debian'

  let(:platform) { 'debian' }
  let(:platform_version) { '8.4' }

  it_behaves_like 'any Debian platform'
end
