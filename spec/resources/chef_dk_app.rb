require_relative '../resources'
require_relative '../../libraries/helpers'

shared_context 'resources::chef_dk_app' do
  include_context 'resources'

  let(:resource) { 'chef_dk_app' }
  %i(version channel source checksum).each { |p| let(p) { nil } }
  let(:properties) do
    { version: version, channel: channel, source: source, checksum: checksum }
  end
  let(:name) { 'default' }

  shared_context 'the default action (:install)' do
    before(:each) do
      allow(Kernel).to receive(:load).and_call_original
      allow(Kernel).to receive(:load)
        .with(%r{chef-dk/libraries/helpers\.rb}).and_return(true)
      allow(ChefDk::Helpers).to receive(:metadata_for).with(
        channel: channel || :stable,
        version: version || 'latest',
        platform: platform,
        platform_version: %r{#{platform_version}.*},
        machine: 'x86_64'
      ).and_return(
        sha1: 'abcd',
        sha256: '1234',
        url: "http://example.com/#{channel || 'stable'}/chefdk",
        version: version || '1.2.3'
      )
    end
  end

  shared_context 'the :remove action' do
    let(:action) { :remove }
    cached(:chef_run) { converge }
  end

  shared_context 'the default source (:direct)' do
    let(:source) { nil }
    cached(:chef_run) { converge }
  end

  shared_context 'the :repo source' do
    let(:source) { :repo }
    cached(:chef_run) { converge }
  end

  shared_context 'a custom source' do
    let(:source) { 'https://example.biz/cdk' }
    let(:checksum) { '12345' }
    cached(:chef_run) { converge }
  end

  shared_context 'all default properties' do
    cached(:chef_run) { converge }
  end

  shared_context 'all other default properties' do
    cached(:chef_run) { converge }
  end

  shared_context 'an overridden channel property' do
    let(:channel) { :current }
    cached(:chef_run) { converge }
  end

  shared_context 'an overridden version property' do
    let(:version) { '4.5.6' }
    cached(:chef_run) { converge }
  end

  shared_examples_for 'any platform' do
    include_context 'the :remove action'
    include_context 'an overridden version property'

    it 'raises an error' do
      e = Chef::Exceptions::ValidationFailed
      expect { chef_run }.to raise_error(e)
    end
  end
end
