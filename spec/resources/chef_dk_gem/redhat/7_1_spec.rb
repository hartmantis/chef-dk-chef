# encoding: utf-8
# frozen_string_literal: true

require_relative '../linux'

describe 'resources::chef_dk_gem::redhat::7_1' do
  include_context 'resources::chef_dk_gem::linux'

  let(:platform) { 'redhat' }
  let(:platform_version) { '7.1' }

  it_behaves_like 'any Linux platform'
end
