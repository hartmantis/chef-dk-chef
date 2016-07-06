require_relative '../windows'

describe 'resources::chef_dk_app::windows::10' do
  include_context 'resources::chef_dk_app::windows'

  let(:platform) { 'windows' }
  let(:platform_version) { '10' }

  it_behaves_like 'any Windows platform'
end
