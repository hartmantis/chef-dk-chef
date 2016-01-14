# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'

describe Chef::Resource::ChefDk do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  [
    :version, :prerelease, :nightlies, :package_url, :global_shell_init
  ].each do |i|
    let(i) { nil }
  end
  let(:resource) do
    r = described_class.new('my_chef_dk', nil)
    [
      :version, :prerelease, :nightlies, :package_url, :global_shell_init
    ].each do |i|
      r.send(i, send(i))
    end
    r
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(
      Fauxhai.mock(platform).data
    )
  end

  shared_examples_for 'an invalid configuration' do
    it 'raises an exception' do
      expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  describe '#initialize' do
    it 'defaults the state to uninstalled' do
      expect(resource.installed?).to eq(false)
    end
  end

  describe '#version' do
    context 'no override provided' do
      it 'defaults to the latest version' do
        expect(resource.version).to eq('latest')
      end
    end

    context 'a valid override provided' do
      let(:version) { '1.2.3-4' }

      it 'returns the override' do
        expect(resource.version).to eq(version)
      end
    end

    context 'an invalid override provided' do
      let(:version) { 'x.y.z' }

      it_behaves_like 'an invalid configuration'
    end

    context 'a version AND package_url provided' do
      let(:version) { '1.2.3-4' }
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#prerelease' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.prerelease).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:prerelease) { true }

      it 'returns the override' do
        expect(resource.prerelease).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:prerelease) { 'monkeys' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#nightlies' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.nightlies).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:nightlies) { true }

      it 'returns the override' do
        expect(resource.nightlies).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:nightlies) { 'monkeys' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#package_url' do
    context 'no override provided' do
      it 'defaults to nil to let the provider calculate a URL' do
        expect(resource.package_url).to eq(nil)
      end
    end

    context 'a valid override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }

      it 'returns the override' do
        expect(resource.package_url).to eq(package_url)
      end
    end

    context 'an invalid override provided' do
      let(:package_url) { :thing }

      it_behaves_like 'an invalid configuration'
    end

    context 'a package_url AND version override provided' do
      let(:package_url) { 'http://example.com/pkg.pkg' }
      let(:version) { '1.2.3-4' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#global_shell_init' do
    context 'no override provided' do
      it 'defaults to false' do
        expect(resource.global_shell_init).to eq(false)
      end
    end

    context 'a valid override provided' do
      let(:global_shell_init) { true }

      it 'returns the override' do
        expect(resource.global_shell_init).to eq(true)
      end
    end

    context 'an invalid override provided' do
      let(:global_shell_init) { 'wiggles' }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#valid_version?' do
    context 'a "latest" version' do
      let(:res) { resource.send(:valid_version?, 'latest') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version' do
      let(:res) { resource.send(:valid_version?, '1.2.3') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'a valid version + build' do
      let(:res) { resource.send(:valid_version?, '1.2.3-12') }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'an invalid version' do
      let(:res) { resource.send(:valid_version?, 'x.y.z') }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
  end
end
