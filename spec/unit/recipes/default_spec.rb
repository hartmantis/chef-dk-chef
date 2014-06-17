# Encoding: UTF-8

require 'spec_helper'

describe 'chef-dk::default' do
  let(:runner) { ChefSpec::Runner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'does something' do
    pending
  end
end
