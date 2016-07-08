require_relative 'spec_helper'

shared_context 'resources' do
  %i(resource name platform platform_version action).each { |p| let(p) { nil } }
  let(:properties) { {} }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: resource, platform: platform, version: platform_version
    ) do |node|
      %i(resource name action).each do |p|
        next if send(p).nil?
        node.default['chef_dk_resource_test'][p] = send(p) unless send(p).nil?
      end
      properties.each do |k, v|
        node.default['chef_dk_resource_test']['properties'][k] = v unless v.nil?
      end
    end
  end
  let(:converge) { runner.converge('chef_dk_resource_test') }
end
