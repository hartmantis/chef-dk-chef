# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_chef_dk'
require_relative '../../libraries/provider_chef_dk'

describe Chef::Provider::ChefDk do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::ChefDk.new(name, run_context) }
  let(:platform) { {} }
  let(:node) { Fauxhai.mock(platform).data }
  let(:provider) { described_class.new(new_resource, run_context) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(node)
  end

  describe '#whyrun_supported?' do
    it 'supports whyrun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#action_install' do
    let(:node) { nil }

    before(:each) do
      %i(chef_gem global_shell_init install!).each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
    end

    shared_examples_for 'any platform' do
      it 'conditionally installs the Omnijack gem' do
        p = provider
        expect(p).to receive(:chef_gem).with('omnijack').and_yield
        expect(p).to receive(:version).with('~> 1.0')
        expect(p).to receive(:compile_time).with(false)
        expect(p).to receive(:only_if).and_yield
        expect(new_resource).to receive(:package_url)
        p.action_install
      end

      it 'calls the child install! method' do
        p = provider
        expect(p).to receive(:install!)
        p.action_install
      end
    end

    context 'Ubuntu' do
      let(:node) { { 'platform' => 'ubuntu' } }

      it_behaves_like 'any platform'

      it 'sends a :create to global_shell_init' do
        p = provider
        expect(p).to receive(:global_shell_init).with(:create)
        p.action_install
      end
    end

    context 'Windows' do
      let(:node) { { 'platform' => 'windows' } }

      it_behaves_like 'any platform'

      it 'does not send a :create to global_shell_init' do
        p = provider
        expect(p).to_not receive(:global_shell_init)
        p.action_install
      end
    end
  end

  describe '#action_remove' do
    let(:node) { nil }

    before(:each) do
      %i(global_shell_init remove!).each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
    end

    shared_examples_for 'any platform' do
      it 'calls the child remove! method' do
        p = provider
        expect(p).to receive(:remove!)
        p.action_remove
      end
    end

    context 'Ubuntu' do
      let(:node) { { 'platform' => 'ubuntu' } }

      it_behaves_like 'any platform'

      it 'sends a :delete to global_shell_init' do
        p = provider
        expect(p).to receive(:global_shell_init).with(:delete)
        p.action_remove
      end
    end

    context 'Windows' do
      let(:node) { { 'platform' => 'windows' } }

      it_behaves_like 'any platform'

      it 'does not send a :delete to global_shell_init' do
        p = provider
        expect(p).to_not receive(:global_shell_init)
        p.action_remove
      end
    end
  end

  %i(install! remove! bashrc_file).each do |m|
    describe "##{m}" do
      it 'raises an error' do
        expect { provider.send(m) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#global_shell_init' do
    let(:bashrc_file) { '/tmp/bashrc' }
    let(:action) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:bashrc_file)
        .and_return(bashrc_file)
    end

    context 'a :create action' do
      let(:action) { :create }

      it 'sets up a ruby_block to create the bashrc entry' do
        p = provider
        expect(p).to receive(:ruby_block).with('create Chef global shell-init')
          .and_yield
        expect(p).to receive(:block).and_yield
        fe = double
        expect(Chef::Util::FileEdit).to receive(:new).with('/tmp/bashrc')
          .and_return(fe)
        expect(fe).to receive(:insert_line_if_no_match).with(
          /^eval "\$\(chef shell-init bash\)"$/,
          'eval "$(chef shell-init bash)"'
        )
        expect(p).to receive(:only_if)
        p.send(:global_shell_init, action)
      end
    end

    context 'a :delete action' do
      let(:action) { :delete }

      it 'sets up a ruby_block to delete the bashrc entry' do
        p = provider
        expect(p).to receive(:ruby_block).with('delete Chef global shell-init')
          .and_yield
        expect(p).to receive(:block).and_yield
        fe = double
        expect(Chef::Util::FileEdit).to receive(:new).with('/tmp/bashrc')
          .and_return(fe)
        expect(fe).to receive(:search_file_delete_line).with(
          /^eval "\$\(chef shell-init bash\)"$/
        )
        expect(p).to receive(:only_if)
        p.send(:global_shell_init, action)
      end
    end
  end

  describe '#package_source' do
    let(:package_url) { nil }
    let(:new_resource) do
      r = super()
      r.package_url(package_url) unless package_url.nil?
      r
    end
    let(:metadata) { double(url: 'http://example.com/chefdk.pkg') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
    end

    context 'no package_url property' do
      let(:package_url) { nil }

      it 'returns the metadata URL' do
        expect(provider.send(:package_source)).to eq(
          'http://example.com/chefdk.pkg'
        )
      end
    end

    context 'a package_url property' do
      let(:package_url) { 'http://example.com/other.pkg' }

      it 'returns the package_url' do
        expect(provider.send(:package_source)).to eq(
          'http://example.com/other.pkg'
        )
      end
    end
  end

  describe '#metadata' do
    let(:yolo) { false }
    let(:metadata) { double(yolo: yolo) }

    before(:each) do
      require 'omnijack'
      allow_any_instance_of(described_class).to receive(:metadata_params)
        .and_return(some: 'things')
      allow_any_instance_of(Omnijack::Project::ChefDk).to receive(:metadata)
        .and_return(metadata)
    end

    it 'fetches and returns the metadata instance' do
      expect(Omnijack::Project::ChefDk).to receive(:new).with(some: 'things')
        .and_call_original
      expect(provider.send(:metadata)).to eq(metadata)
    end

    context 'a "yolo" package' do
      let(:yolo) { true }

      it 'logs a warning to Chef' do
        expect(Chef::Log).to receive(:warn).with('Using a ChefDk package ' \
                                                 'not officially supported ' \
                                                 'on this platform')
        provider.send(:metadata)
      end
    end
  end

  describe '#metadata_params' do
    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it 'returns the correct params hash' do
        expected = {
          platform: 'ubuntu',
          platform_version: '14.04',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }

      it 'returns the correct params hash' do
        expected = {
          platform: 'mac_os_x',
          platform_version: '10.9.2',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it 'returns the correct params hash' do
        expected = {
          platform: 'windows',
          platform_version: '6.3.9600',
          machine_arch: 'x86_64',
          version: 'latest',
          prerelease: false,
          nightlies: false
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end
  end
end
