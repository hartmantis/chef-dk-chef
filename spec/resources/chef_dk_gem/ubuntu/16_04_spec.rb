# encoding: utf-8
# frozen_string_literal: true

require_relative '../linux'

describe 'resources::chef_dk_gem::ubuntu::16_04' do
  include_context 'resources::chef_dk_gem::linux'

  let(:platform) { 'ubuntu' }
  let(:platform_version) { '16.04' }

  it_behaves_like 'any Linux platform'
end
