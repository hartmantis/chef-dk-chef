# frozen_string_literal: true
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

  let(:installed_version) { nil }

  shared_examples_for 'any platform' do
    context 'the default action (:install)' do
      context 'a custom source' do
        let(:source) { 'https://example.biz.cdk' }

        context 'an overridden channel property' do
          let(:channel) { :current }

          it 'raises an error' do
            expect { chef_run }.to raise_error(
              Chef::Exceptions::UnsupportedAction
            )
          end
        end

        context 'an overridden version property' do
          let(:version) { '4.5.6' }

          it 'raises an error' do
            expect { chef_run }.to raise_error(
              Chef::Exceptions::UnsupportedAction
            )
          end
        end
      end
    end

    context 'the :upgrade action' do
      let(:action) { :upgrade }

      context 'a custom source' do
        let(:source) { 'https://example.biz.cdk' }

        it 'raises an error' do
          expect { chef_run }.to raise_error(
            Chef::Exceptions::UnsupportedAction
          )
        end
      end

      context 'an overridden version property' do
        let(:version) { '1.2.3' }

        it 'raises an error' do
          expect { chef_run }.to raise_error(
            Chef::Exceptions::UnsupportedAction
          )
        end
      end
    end
  end

  shared_context 'the default action (:install)' do
    before(:each) do
      allow(Kernel).to receive(:load).and_call_original
      allow(Kernel).to receive(:load)
        .with(%r{chef-dk/libraries/helpers\.rb}).and_return(true)
      allow(ChefDk::Helpers).to receive(:metadata_for).with(
        channel: channel || :stable,
        version: version || 'latest',
        platform: platform,
        platform_version: /#{platform_version}.*/,
        machine: 'x86_64'
      ).and_return(
        sha1: 'abcd',
        sha256: '1234',
        url: "http://example.com/#{channel || 'stable'}/chefdk",
        version: version || '1.2.3'
      )
    end
  end

  shared_context 'the :upgrade action' do
    let(:action) { :upgrade }

    before(:each) do
      allow(Kernel).to receive(:load).and_call_original
      allow(Kernel).to receive(:load)
        .with(%r{chef-dk/libraries/helpers\.rb}).and_return(true)
      allow(ChefDk::Helpers).to receive(:metadata_for).with(
        channel: channel || :stable,
        version: version || 'latest',
        platform: platform,
        platform_version: /#{platform_version}.*/,
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
  end

  shared_context 'the default source (:direct)' do
    let(:source) { nil }
  end

  shared_context 'the :repo source' do
    let(:source) { :repo }
  end

  shared_context 'a custom source' do
    let(:source) { 'https://example.biz/cdk' }
    let(:checksum) { '12345' }
  end

  shared_context 'all default properties' do
  end

  shared_context 'an overridden channel property' do
    let(:channel) { :current }
  end

  shared_context 'an overridden version property' do
    let(:version) { '4.5.6' }
  end

  shared_context 'the latest version already installed' do
    let(:installed_version) { '1.2.3' }
  end

  shared_context 'an older version already installed' do
    let(:installed_version) { '0.1.2' }
  end
end
