# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::windows' do
  include_context 'resources::chef_dk_app'

  before(:each) do
    stdout = <<-EOH.gsub(/^ +/, '')
      IdentifyingNumber   : {abc123}
      Name                : Test App 3.1.4
      Vendor              : Thumb Monkey Industries
      Version             : 3.1.41.1
      Caption             : Test App 3.1.4
    EOH
    installed_version && stdout << <<-EOH.gsub(/^ +/, '')

      IdentifyingNumber   : {456789}
      Name                : Chef Development Kit #{installed_version}
      Vendor              : Chef Software, Inc.
      Version             : #{installed_version}.1
      Caption             : Chef Development Kit v#{installed_version}
    EOH
    allow_any_instance_of(Chef::Mixin::PowershellOut)
      .to receive(:powershell_out!)
      .with('Get-WmiObject -Class win32_product')
      .and_return(double(stdout: stdout))
  end

  shared_examples_for 'any Windows platform' do
    it_behaves_like 'any platform'

    context 'the default action (:install)' do
      include_context description

      context 'the default source (:direct)' do
        include_context description

        shared_examples_for 'installs Chef-DK' do
          it 'installs the correct Chef-DK package' do
            pkg = "Chef Development Kit v#{version || '1.2.3'}"
            expect(chef_run).to install_package(pkg).with(
              source: "http://example.com/#{channel || 'stable'}/chefdk",
              checksum: '1234'
            )
          end
        end

        shared_examples_for 'does not install Chef-DK' do
          it 'does not install the correct Chef-DK package' do
            pkg = "Chef Development Kit v#{version || '1.2.3'}"
            expect(chef_run).to_not install_package(pkg)
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
          allow_any_instance_of(Chef::Resource)
            .to receive(:chocolatey_installed?).and_return(false)
        end

        [
          'all default properties',
          'an overridden version property'
        ].each do |c|
          context c do
            include_context description

            it 'ensures Chocolatey is installed' do
              expect(chef_run).to include_recipe('chocolatey')
            end

            it 'installs the chefdk Chocolatey package' do
              expect(chef_run).to install_chocolatey_package('chefdk')
                .with(version: version && [version])
            end
          end
        end

        context 'an overridden channel property' do
          include_context description

          it 'raises an error' do
            expect { chef_run }.to raise_error(
              Chef::Exceptions::UnsupportedAction
            )
          end
        end
      end

      context 'a custom source' do
        include_context description

        shared_examples_for 'does not install Chef-DK' do
          it 'does not install the correct Chef-DK package' do
            pkg = "Chef Development Kit v#{version || '1.2.3'}"
            expect(chef_run).to_not install_package(pkg)
          end
        end

        context 'all default properties' do
          include_context description

          it 'installs the correct Chef-DK package' do
            pkg = "Chef Development Kit v#{version || '1.2.3'}"
            expect(chef_run).to install_package(pkg).with(
              source: 'https://example.biz/cdk',
              checksum: '12345'
            )
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

    context 'the :upgrade action' do
      include_context description

      context 'the default source (:direct)' do
        include_context description

        shared_examples_for 'upgrades Chef-DK' do
          it 'installs the correct Chef-DK package' do
            pkg = 'Chef Development Kit v1.2.3'
            expect(chef_run).to install_package(pkg).with(
              source: "http://example.com/#{channel || 'stable'}/chefdk",
              checksum: '1234'
            )
          end
        end

        shared_examples_for 'does not upgrade Chef-DK' do
          it 'does not install the correct Chef-DK package' do
            pkg = 'Chef Development Kit v1.2.3'
            expect(chef_run).to_not install_package(pkg)
          end
        end

        [
          'all default properties',
          'an overridden channel property'
        ].each do |c|
          context c do
            include_context description

            it_behaves_like 'upgrades Chef-DK'
          end
        end

        context 'the latest version already installed' do
          include_context description

          it_behaves_like 'does not upgrade Chef-DK'
        end

        context 'an older version already installed' do
          include_context description

          it_behaves_like 'upgrades Chef-DK'
        end
      end

      context 'the :repo source' do
        include_context description

        before(:each) do
          allow_any_instance_of(Chef::Resource)
            .to receive(:chocolatey_installed?).and_return(false)
        end

        context 'all default properties' do
          include_context description

          it 'ensures Chocolatey is installed' do
            expect(chef_run).to include_recipe('chocolatey')
          end

          it 'installs the chefdk Chocolatey package' do
            expect(chef_run).to upgrade_chocolatey_package('chefdk')
              .with(version: nil)
          end
        end

        context 'an overridden channel property' do
          include_context description

          it 'raises an error' do
            expect { chef_run }.to raise_error(
              Chef::Exceptions::UnsupportedAction
            )
          end
        end
      end

      context 'a custom source' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'raises an error' do
            expect { chef_run }
              .to raise_error(Chef::Exceptions::UnsupportedAction)
          end
        end
      end
    end

    context 'the :remove action' do
      include_context description

      let(:listed?) { true }
      let(:pkg_list) do
        pl = <<-EOH.gsub(/^ +/, '')
          IdentifyingNumber   : {abc123}
          Name                : Test App 3.1.4
          Vendor              : Thumb Monkey Industries
          Version             : 3.1.41.1
          Caption             : Test App 3.1.4
        EOH
        listed? && pl << <<-EOH.gsub(/^ +/, '')

          IdentifyingNumber   : {456789}
          Name                : Chef Development Kit v0.16.28
          Vendor              : Chef Software, Inc.
          Version             : 0.16.28.1
          Caption             : Chef Development Kit v0.16.28
        EOH
        pl
      end

      before(:each) do
        allow_any_instance_of(Chef::Mixin::PowershellOut)
          .to receive(:powershell_out!)
          .with('Get-WmiObject -Class win32_product')
          .and_return(double(stdout: pkg_list))
      end

      [
        'the default source (:direct)',
        'a custom source'
      ].each do |c|
        context c do
          include_context description

          it 'deletes the Chef-DK AppData directory' do
            d = File.expand_path('~/AppData/Local/chefdk')
            expect(chef_run).to delete_directory(d).with(recursive: true)
          end

          context 'app in the installed list' do
            let(:listed?) { true }

            it 'removes the Chef-DK Windows package' do
              expect(chef_run).to run_execute(
                'Uninstall Chef Development Kit v0.16.28'
              ).with(command: 'msiexec /qn /x "{456789}"')
            end
          end

          context 'app not in the installed list' do
            let(:listed?) { false }

            it 'falls back to a default package name' do
              expect(chef_run).to remove_package('Chef Development Kit')
            end
          end
        end
      end

      context 'the :repo source' do
        include_context description

        it 'purges the chefdk Chocolatey package' do
          expect(chef_run).to remove_chocolatey_package('chefdk')
        end
      end
    end
  end
end
