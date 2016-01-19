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
    let(:global_shell_init) { double(write_file: true) }

    before(:each) do
      %i(chef_gem install!).each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .with(:create).and_return(global_shell_init)
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

      it 'writes the bashrc file' do
        expect(global_shell_init).to receive(:write_file)
        provider.action_install
      end
    end

    context 'Windows' do
      let(:node) { { 'platform' => 'windows' } }

      it_behaves_like 'any platform'

      it 'does not write the bashrc file' do
        expect(global_shell_init).to_not receive(:write_file)
        provider.action_install
      end
    end
  end

  describe '#action_remove' do
    let(:node) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:remove!)
      allow_any_instance_of(described_class).to receive(:node).and_return(node)
      allow_any_instance_of(described_class).to receive(:global_shell_init)
        .with(:delete).and_return(global_shell_init)
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

      it 'writes the bashrc file' do
        expect(global_shell_init).to receive(:write_file)
        provider.action_install
      end
    end

    context 'Windows' do
      let(:node) { { 'platform' => 'windows' } }

      it_behaves_like 'any platform'

      it 'does not write the bashrc file' do
        expect(global_shell_init).to_not receive(:write_file)
        provider.action_install
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
      let(:platform) { { platform: 'windows', version: '2012R2' } }

      it 'returns the correct params hash' do
        expected = {
          platform: 'windows',
          platform_version: '6.3.9600',
          machine_arch: 'x86_64',
          version: nil,
          prerelease: nil,
          nightlies: nil
        }
        expect(provider.send(:metadata_params)).to eq(expected)
      end
    end
  end
end
