# frozen_string_literal: true
require_relative '../rhel'

describe 'resources::chef_dk_app::fedora::23' do
  include_context 'resources::chef_dk_app::rhel'

  let(:platform) { 'fedora' }
  let(:platform_version) { '23' }

  it_behaves_like 'any RHEL platform'
end
