# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/chef_dk_helpers'

describe ChefDk::Helpers do
  describe '#metadata_for' do
    let(:node) { 'nodestub' }
    let(:new_resource) { Chef::Resource::ChefDk.new('default', nil) }
    let(:yolo) { false }
    let(:metadata) { double(yolo: yolo) }

    before(:each) do
      require 'omnijack'
      allow(described_class).to receive(:metadata_params_for)
        .with(node, new_resource).and_return(some: 'things')
      allow(Omnijack::Project::ChefDk).to receive(:new).with(some: 'things')
        .and_return(double(metadata: metadata))
    end

    it 'fetches and returns the metadata instance' do
      expect(described_class.metadata_for(node, new_resource)).to eq(metadata)
    end

    context 'a "yolo" package' do
      let(:yolo) { true }

      it 'logs a warning to Chef' do
        expect(Chef::Log).to receive(:warn)
          .with('Using a ChefDk package not officially supported on this ' \
                'platform')
        described_class.metadata_for(node, new_resource)
      end
    end

    context 'a package_url provided' do
      let(:new_resource) do
        r = super()
        r.package_url('http://example.com/chefdk.pkg')
        r
      end

      it 'returns nil' do
        expect(described_class.metadata_for(node, new_resource)).to eq(nil)
      end
    end
  end

  describe '#metadata_params_for' do
    let(:platform) { nil }
    let(:new_resource) { Chef::Resource::ChefDk.new('default', nil) }
    let(:node) { Fauxhai.mock(platform).data }

    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it 'returns the correct params hash' do
        expect(described_class.metadata_params_for(node, new_resource)).to eq(
          platform: 'ubuntu',
          platform_version: '14.04',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        )
      end
    end

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }

      it 'returns the correct params hash' do
        expect(described_class.metadata_params_for(node, new_resource)).to eq(
          platform: 'mac_os_x',
          platform_version: '10.9.2',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        )
      end
    end

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it 'returns the correct params hash' do
        expect(described_class.metadata_params_for(node, new_resource)).to eq(
          platform: 'windows',
          platform_version: '6.3.9600',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        )
      end
    end
  end
end
