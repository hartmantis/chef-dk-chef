# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_chef_dk'

describe Chef::Provider::ChefDk do
  let(:base_url) { 'https://opscode-omnibus-packages.s3.amazonaws.com' }
  let(:platform) { {} }
  [
    :version, :prerelease, :nightlies, :package_url, :global_shell_init
  ].each { |i| let(i) { nil } }
  let(:node) { Fauxhai.mock(platform).data }
  let(:new_resource) do
    double(name: 'my_chef_dk',
           cookbook_name: 'chef-dk',
           version: version,
           prerelease: prerelease,
           nightlies: nightlies,
           package_url: package_url,
           global_shell_init: global_shell_init,
           :installed= => true)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:node).and_return(node)
  end

  describe '#whyrun_supported?' do
    it 'supports whyrun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    it 'returns a ChefDk resource' do
      expected = Chef::Resource::ChefDk
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_install' do
    [:omnijack_gem, :remote_file, :package].each do |i|
      let(i) { double(run_action: true) }
    end
    let(:gsi) { double(write_file: true) }
    let(:yolo) { false }
    let(:metadata) { double(yolo: yolo) }

    before(:each) do
      [:omnijack_gem, :remote_file, :package, :metadata].each do |r|
        allow_any_instance_of(described_class).to receive(r)
          .and_return(send(r))
      end
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(gsi)
    end

    shared_examples_for 'any platform' do
      it 'downloads the package remote file' do
        expect(remote_file).to receive(:run_action).with(:create)
        provider.action_install
      end

      it 'installs the package file' do
        expect(package).to receive(:run_action).with(:install)
        provider.action_install
      end

      it 'sets the installed state to true' do
        expect(new_resource).to receive(:'installed=').with(true)
        provider.action_install
      end
    end

    shared_examples_for 'a platform with a bashrc' do
      it 'calls the bashrc create logic' do
        expect_any_instance_of(described_class).to receive(:global_shell_init)
          .with(:create)
        expect(gsi).to receive(:write_file)
        provider.action_install
      end
    end

    shared_examples_for 'no package_url provided' do
      it 'installs the omnijack gem' do
        expect(omnijack_gem).to receive(:run_action).with(:install)
        provider.action_install
      end
    end

    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it_behaves_like 'any platform'
      it_behaves_like 'a platform with a bashrc'
      it_behaves_like 'no package_url provided'
    end

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

      it_behaves_like 'any platform'
      it_behaves_like 'a platform with a bashrc'
      it_behaves_like 'no package_url provided'
    end

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it_behaves_like 'any platform'
      it_behaves_like 'no package_url provided'

      it 'does not call the bashrc create logic' do
        expect_any_instance_of(described_class)
          .not_to receive(:global_shell_init)
        provider.action_remove
      end
    end

    context 'a "yolo" package' do
      let(:yolo) { true }

      it 'logs a warning to Chef' do
        expect(Chef::Log).to receive(:warn).with('Using a ChefDk package ' \
                                                 'not officially supported ' \
                                                 'on this platform')
        provider.action_install
      end
    end

    context 'a package_url provided' do
      let(:package_url) { 'http://example.com/pkg' }

      it 'skips the Omnijack gem' do
        expect_any_instance_of(described_class).not_to receive(:omnijack_gem)
        expect_any_instance_of(described_class).not_to receive(:metadata)
        provider.action_install
      end
    end
  end

  describe '#action_remove' do
    let(:remote_file) { double(run_action: true) }
    let(:package) { double(run_action: true) }
    let(:gsi) { double(write_file: true) }

    before(:each) do
      [:remote_file, :package].each do |r|
        allow_any_instance_of(described_class).to receive(r)
          .and_return(send(r))
      end
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .and_return(gsi)
    end

    shared_examples_for 'any platform' do
      it 'deletes the package remote file' do
        expect(remote_file).to receive(:run_action).with(:delete)
        provider.action_remove
      end

      it 'installs the package file' do
        expect(package).to receive(:run_action).with(:remove)
        provider.action_remove
      end

      it 'sets the installed state to false' do
        expect(new_resource).to receive(:'installed=').with(false)
        provider.action_remove
      end
    end

    shared_examples_for 'a platform with a bashrc' do
      it 'calls the bashrc delete logic' do
        expect_any_instance_of(described_class).to receive(:global_shell_init)
          .with(:delete)
        expect(gsi).to receive(:write_file)
        provider.action_remove
      end
    end

    context 'Ubuntu' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it_behaves_like 'any platform'
      it_behaves_like 'a platform with a bashrc'
    end

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

      it_behaves_like 'any platform'
      it_behaves_like 'a platform with a bashrc'
    end

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it_behaves_like 'any platform'

      it 'does not call the bashrc delete logic' do
        expect_any_instance_of(described_class)
          .not_to receive(:global_shell_init)
        provider.action_remove
      end
    end
  end

  describe '#package' do
    let(:package_resource_class) { Chef::Resource::Package }
    let(:package_provider_class) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(
        :package_resource_class).and_return(package_resource_class)
      allow_any_instance_of(described_class).to receive(
        :package_provider_class).and_return(package_provider_class)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/blah.pkg')
      allow_any_instance_of(described_class).to receive(
        :tailor_package_resource_to_platform).and_return(true)
    end

    shared_examples_for 'any node' do
      it 'returns a package resource' do
        expected = package_resource_class
        expect(provider.send(:package)).to be_an_instance_of(expected)
      end
    end

    context 'all default' do
      it_behaves_like 'any node'

      it 'does not call a custom provider' do
        expect_any_instance_of(package_resource_class).to_not receive(:provider)
        provider.send(:package)
      end
    end

    context 'with custom resource and provider classes given' do
      let(:package_resource_class) { Chef::Resource::DmgPackage }
      let(:package_provider_class) { Chef::Provider::DmgPackage }

      it_behaves_like 'any node'

      it 'calls the custom provider' do
        expect_any_instance_of(package_resource_class).to receive(:provider)
          .with(package_provider_class)
        provider.send(:package)
      end
    end
  end

  describe '#tailor_package_resource_to_platform' do
    let(:package) { double(version: true) }
    let(:provider) do
      p = described_class.new(new_resource, nil)
      p.instance_variable_set(:@package, package)
      p
    end
    let(:version) { '6.6.6' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:version)
        .and_return(version)
    end

    it 'does a version call on the package resource' do
      expect(package).to receive(:version).with(version)
      provider.send(:tailor_package_resource_to_platform)
    end
  end

  describe '#package_resource_class' do
    it 'returns Chef::Resource::Package' do
      expected = Chef::Resource::Package
      expect(provider.send(:package_resource_class)).to eq(expected)
    end
  end

  describe '#package_provider_class' do
    it 'returns nil' do
      expect(provider.send(:package_provider_class)).to eq(nil)
    end
  end

  describe '#global_shell_init' do
    let(:action) { nil }
    let(:res) { provider.send(:global_shell_init, action) }

    before(:each) do
      @fakebashrc = Tempfile.new('chefdkspec')
      allow_any_instance_of(described_class).to receive(:bashrc_file)
        .and_return(@fakebashrc.path)
    end

    after(:each) do
      @fakebashrc.delete
    end

    shared_examples_for 'any instance' do
      it 'returns a FileEdit object' do
        expect(res).to be_an_instance_of(Chef::Util::FileEdit)
      end
    end

    shared_examples_for 'no action' do
      it 'does not call insert_line_if_no_match' do
        expect_any_instance_of(Chef::Util::FileEdit)
          .not_to receive(:insert_line_if_no_match)
      end

      it 'does not call search_file_delete_line' do
        expect_any_instance_of(Chef::Util::FileEdit)
          .not_to receive(:search_file_delete_line)
      end

      it 'will do nothing to the file' do
        @fakebashrc.write('some stuff')
        @fakebashrc.seek(0)
        res
        @fakebashrc.seek(0)
        expect(@fakebashrc.read).to eq('some stuff')
      end
    end

    context 'no action (default)' do
      context 'global shell init disabled (default)' do
        it_behaves_like 'any instance'
        it_behaves_like 'no action'
      end

      context 'global shell init enabled' do
        let(:global_shell_init) { true }

        it_behaves_like 'any instance'
        it_behaves_like 'no action'
      end
    end

    context 'a create action' do
      let(:action) { :create }

      context 'global shell init disabled (default)' do
        it_behaves_like 'any instance'
        it_behaves_like 'no action'
      end

      context 'global shell init enabled' do
        let(:global_shell_init) { true }

        it_behaves_like 'any instance'

        it 'calls insert_line_if_no_match' do
          expect_any_instance_of(Chef::Util::FileEdit)
            .to receive(:insert_line_if_no_match)
          res
        end

        it 'will write to the file' do
          res.write_file
          @fakebashrc.seek(0)
          expected = "eval \"$(chef shell-init bash)\"\n"
          expect(@fakebashrc.read).to eq(expected)
        end
      end
    end

    context 'a delete action' do
      let(:action) { :delete }

      context 'global shell init disabled (default)' do
        it_behaves_like 'any instance'
        it_behaves_like 'no action'
      end

      context 'global shell init enabled' do
        let(:global_shell_init) { true }

        it 'calls search_file_delete_line' do
          expect_any_instance_of(Chef::Util::FileEdit)
            .to receive(:search_file_delete_line)
          res
        end

        it 'will delete from the file' do
          @fakebashrc.write("eval \"$(chef shell-init bash)\"\n")
          @fakebashrc.seek(0)
          res.write_file
          @fakebashrc.seek(0)
          expect(@fakebashrc.read).to eq('')
        end
      end
    end
  end

  describe '#remote_file' do
    let(:metadata) { double(url: 'http://x.com/pack.pkg', sha256: 'lolnope') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/pack.pkg')
    end

    shared_examples_for 'any node' do
      it 'returns an instance of Chef::Resource::RemoteFile' do
        expected = Chef::Resource::RemoteFile
        expect(provider.send(:remote_file)).to be_an_instance_of(expected)
      end
    end

    context 'no package_url (default)' do
      it_behaves_like 'any node'

      it 'sets the file source' do
        expect_any_instance_of(Chef::Resource::RemoteFile).to receive(:source)
          .with('http://x.com/pack.pkg')
        provider.send(:remote_file)
      end

      it 'sets the file checksum' do
        expect_any_instance_of(Chef::Resource::RemoteFile).to receive(:checksum)
          .with('lolnope')
        provider.send(:remote_file)
      end
    end

    context 'a package_url provided' do
      let(:package_url) { 'file:///tmp/path/thing.deb' }

      it_behaves_like 'any node'

      it 'sets the file source' do
        expect_any_instance_of(Chef::Resource::RemoteFile).to receive(:source)
          .with('file:///tmp/path/thing.deb')
        provider.send(:remote_file)
      end

      it 'sets no file checksum' do
        expect_any_instance_of(Chef::Resource::RemoteFile)
          .not_to receive(:checksum)
        provider.send(:remote_file)
      end
    end
  end

  describe '#download_path' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:filename)
        .and_return('test.deb')
    end

    it 'returns a path in the Chef file_cache_path' do
      expected = File.join(Chef::Config[:file_cache_path], 'test.deb')
      expect(provider.send(:download_path)).to eq(expected)
    end
  end

  describe '#filename' do
    let(:metadata) { double(filename: 'test.deb') }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:metadata)
        .and_return(metadata)
    end

    context 'no package_url (default)' do
      it 'returns a filename from the metadata' do
        expect(provider.send(:filename)).to eq('test.deb')
      end
    end

    context 'a package_url provided' do
      let(:package_url) { 'file:///tmp/somewhere/package.pkg' }

      it 'returns the base name of the package_url file' do
        expect(provider.send(:filename)).to eq('package.pkg')
      end
    end
  end

  describe '#metadata' do
    before(:each) do
      require 'omnijack'
      allow_any_instance_of(described_class).to receive(:metadata_params)
        .and_return(some: 'things')
      allow_any_instance_of(Omnijack::Project::ChefDk).to receive(:metadata)
        .and_return('SOME METADATA')
    end

    it 'fetches and returns the metadata instance' do
      expect(Omnijack::Project::ChefDk).to receive(:new).with(some: 'things')
        .and_call_original
      expect(provider.send(:metadata)).to eq('SOME METADATA')
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
          version: nil,
          prerelease: nil,
          nightlies: nil
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
          version: nil,
          prerelease: nil,
          nightlies: nil
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end

    context 'Windows' do
      let(:platform) { { platform: 'windows', version: '2012' } }

      it 'returns the correct params hash' do
        expected = {
          platform: 'windows',
          platform_version: '6.2.9200',
          machine_arch: 'x86_64',
          version: nil,
          prerelease: nil,
          nightlies: nil
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end
  end

  describe '#omnijack_gem' do
    it 'returns a ChefGem instance' do
      expected = Chef::Resource::ChefGem
      expect(provider.send(:omnijack_gem)).to be_an_instance_of(expected)
    end
  end

  describe '#bashrc_file' do
    it 'raises an error' do
      expect { provider.send(:bashrc_file) }.to raise_error(
        Chef::Provider::ChefDk::NotImplemented
      )
    end
  end
end
