# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_gem'

shared_context 'resources::chef_dk_gem::windows' do
  include_context 'resources::chef_dk_gem'

  let(:gem_path) { File.expand_path('/opscode/chefdk/embedded/bin/gem') }

  shared_examples_for 'any Windows platform' do
    it_behaves_like 'any platform'
  end
end
