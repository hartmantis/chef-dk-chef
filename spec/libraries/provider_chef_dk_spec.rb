# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/provider_chef_dk'

describe Chef::Provider::ChefDk do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '#whyrun_supported?' do
    it 'supports whyrun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#action_install' do
    let(:global_shell_init) { nil }
    let(:platform_family) { double }
    let(:node) { { 'platform_family' => platform_family } }
    let(:new_resource) do
      r = super()
      r.global_shell_init(global_shell_init) unless global_shell_init.nil?
      r
    end

    before(:each) do
      %i(chef_gem install! chef_dk_shell_init).each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
    end

    shared_examples_for 'any platform' do
      it 'conditionally installs the Omnijack gem' do
        p = provider
        expect(p).to receive(:chef_gem).with('omnijack').and_yield
        expect(p).to receive(:version).with('~> 1.0')
        expect(p).to receive(:compile_time).with(true)
        expect(p).to receive(:not_if).and_yield
        expect(new_resource).to receive(:package_url)
        p.action_install
      end

      it 'calls the child install! method' do
        p = provider
        expect(p).to receive(:install!)
        p.action_install
      end
    end

    context 'no global shell init' do
      let(:global_shell_init) { false }

      it_behaves_like 'any platform'

      it 'disables global shell init' do
        p = provider
        expect(p).to receive(:chef_dk_shell_init).with(name).and_yield
        expect(p).to receive(:action).with(:disable)
        expect(p).to receive(:only_if).and_yield
        expect(platform_family).to receive(:!=).with('windows')
        p.action_install
      end
    end

    context 'global shell init' do
      let(:global_shell_init) { true }

      it_behaves_like 'any platform'

      it 'enables global shell init' do
        p = provider
        expect(p).to receive(:chef_dk_shell_init).with(name).and_yield
        expect(p).to receive(:action).with(:enable)
        expect(p).to receive(:only_if).and_yield
        expect(platform_family).to receive(:!=).with('windows')
        p.action_install
      end
    end
  end

  describe '#action_remove' do
    let(:platform_family) { double }
    let(:node) { { 'platform_family' => platform_family } }

    before(:each) do
      %i(chef_dk_shell_init remove!).each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
    end

    it 'disables the global shell init' do
      p = provider
      expect(p).to receive(:chef_dk_shell_init).with(name).and_yield
      expect(p).to receive(:action).with(:disable)
      expect(p).to receive(:only_if).and_yield
      expect(platform_family).to receive(:!=).with('windows')
      p.action_remove
    end

    it 'calls the child remove! method' do
      p = provider
      expect(p).to receive(:remove!)
      p.action_remove
    end
  end

  %i(install! remove!).each do |m|
    describe "##{m}" do
      it 'raises an error' do
        expect { provider.send(m) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#package_checksum' do
    let(:package_metadata) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:package_metadata)
        .and_return(package_metadata)
    end

    context 'package metadata' do
      let(:package_metadata) { double(sha256: '12345') }

      it 'returns the metadata sha' do
        expect(provider.send(:package_checksum)).to eq('12345')
      end
    end

    context 'no package metadata' do
      let(:package_metadata) { nil }

      it 'returns nil' do
        expect(provider.send(:package_checksum)).to eq(nil)
      end
    end
  end

  describe '#package_source' do
    let(:package_url) { nil }
    let(:package_metadata) { double(url: 'http://example.com/chefdk.pkg') }
    let(:new_resource) do
      r = super()
      r.package_url(package_url) unless package_url.nil?
      r
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:package_metadata)
        .and_return(package_metadata)
    end

    context 'no package_url property' do
      let(:package_url) { nil }

      it 'returns the metadata source' do
        expected = 'http://example.com/chefdk.pkg'
        expect(provider.send(:package_source)).to eq(expected)
      end
    end

    context 'a package_url property' do
      let(:package_url) { 'http://example.com/other.pkg' }

      it 'returns the package_url property' do
        expected = 'http://example.com/other.pkg'
        expect(provider.send(:package_source)).to eq(expected)
      end
    end
  end

  describe '#package_metadata' do
    before(:each) do
      %w(node new_resource).each do |m|
        allow_any_instance_of(described_class).to receive(m.to_sym)
          .and_return(m)
      end
      allow(ChefDk::Helpers).to receive(:metadata_for)
        .with('node', 'new_resource').and_return('metadata')
    end

    it 'returns the package metadata' do
      expect(provider.send(:package_metadata)).to eq('metadata')
    end
  end
end
