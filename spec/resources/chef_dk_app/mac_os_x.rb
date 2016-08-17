# frozen_string_literal: true
require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::mac_os_x' do
  include_context 'resources::chef_dk_app'

  let(:installed_version) { nil }

  before(:each) do
    allow_any_instance_of(Chef::Mixin::HomebrewUser).to receive(:new)
      .and_return(double(find_homebrew_uid: 501))
    allow(Etc).to receive(:getpwuid).with(501).and_return(double: 'homebrew')
    allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out)
      .with('pkgutil --pkg-info com.getchef.pkg.chefdk')
      .and_return(double(exitstatus: installed_version.nil? ? 1 : 0,
                         stdout: "test\nversion: #{installed_version}\nthings"))
  end

  shared_examples_for 'any Mac OS X platform' do
    context 'the default action (:install)' do
      include_context description

      context 'the default source (:direct)' do
        include_context description

        shared_examples_for 'installs Chef-DK' do
          it 'installs the correct Chef-DK package' do
            expect(chef_run).to install_dmg_package('Chef Development Kit')
              .with(app: 'chefdk',
                    volumes_dir: 'Chef Development Kit',
                    source: "http://example.com/#{channel || 'stable'}/chefdk",
                    type: 'pkg',
                    package_id: 'com.getchef.pkg.chefdk',
                    checksum: '1234')
          end
        end

        shared_examples_for 'does not install Chef-DK' do
          it 'does not install the correct Chef-DK package' do
            expect(chef_run).to_not install_dmg_package('Chef Development Kit')
          end
        end

        [
          'all default properties',
          'an overridden channel property',
          'an overridden version property'
        ].each do |c|
          context c do
            include_context description

            it_behaves_like 'installs Chef-DK'
          end
        end

        context 'the latest version already installed' do
          include_context description

          it_behaves_like 'does not install Chef-DK'
        end

        context 'an older version already installed' do
          include_context description

          it_behaves_like 'does not install Chef-DK'
        end
      end

      context 'the :repo source' do
        include_context description

        before(:each) do
          stub_command('which git').and_return('/usr/bin/git')
        end

        context 'all default properties' do
          include_context description

          it 'ensures Homebrew is installed' do
            expect(chef_run).to include_recipe('homebrew')
          end

          it 'installs the chefdk Homebrew cask' do
            expect(chef_run).to install_homebrew_cask('chefdk')
          end
        end

        context 'an overridden version property' do
          include_context description

          it 'raises an error' do
            pending
            expect(false).to eq(true)
          end
        end

        context 'an overridden channel property' do
          include_context description

          it 'raises an error' do
            pending
            expect(false).to eq(true)
          end
        end
      end

      context 'a custom source' do
        include_context description

        shared_examples_for 'does not install Chef-DK' do
          it 'does not install the correct Chef-DK package' do
            expect(chef_run).to_not install_dmg_package('Chef Development Kit')
          end
        end

        context 'all default properties' do
          include_context description

          it 'installs the correct Chef-DK package' do
            expect(chef_run).to install_dmg_package('Chef Development Kit')
              .with(app: 'cdk',
                    volumes_dir: 'Chef Development Kit',
                    source: 'https://example.biz/cdk',
                    type: 'pkg',
                    package_id: 'com.getchef.pkg.chefdk',
                    checksum: '12345')
          end
        end

        context 'an overridden channel property' do
          include_context description

          it 'raises an error' do
            pending
            expect(true).to eq(false)
          end
        end

        context 'an overridden version property' do
          include_context description

          it 'raises an error' do
            pending
            expect(true).to eq(false)
          end
        end

        context 'the latest version already installed' do
          include_context description

          it_behaves_like 'does not install Chef-DK'
        end

        context 'an older version already installed' do
          include_context description

          it_behaves_like 'does not install Chef-DK'
        end
      end
    end

    context 'the :remove action' do
      include_context description

      [
        'the default source (:direct)',
        'a custom source'
      ].each do |c|
        context c do
          include_context description

          before(:each) do
            stub_command('pkgutil --pkg-info com.getchef.pkg.chefdk')
              .and_return('somestuff')
          end

          it 'deletes the main chefdk directory' do
            expect(chef_run).to delete_directory('/opt/chefdk')
              .with(recursive: true)
          end

          it 'deletes the chefdk user directory' do
            expect(chef_run).to delete_directory(
              File.expand_path('~/.chefdk')
            ).with(recursive: true)
          end

          it 'forgets the chefdk package' do
            expect(chef_run).to run_execute(
              'pkgutil --forget com.getchef.pkg.chefdk'
            )
          end
        end
      end

      context 'the :repo source' do
        include_context description

        it 'removes the chefdk Homebrew package' do
          expect(chef_run).to uninstall_homebrew_cask('chefdk')
        end
      end
    end
  end
end
