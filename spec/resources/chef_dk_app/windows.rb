# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::windows' do
  include_context 'resources::chef_dk_app'

  before do
    bit64_reg = 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'
    bit32_reg = 'HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\' \
                'CurrentVersion\\Uninstall'

    bit64_subkeys = %w[App1 App2 App3]
    bit32_subkeys = %w[App4 App5]
    bit32_subkeys << 'ChefDkApp' if installed_version

    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_subkeys).with(bit64_reg)
      .and_return(bit64_subkeys)
    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_subkeys).with(bit32_reg)
      .and_return(bit32_subkeys)

    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_values).with("#{bit64_reg}\\App1")
      .and_return([])
    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_values).with("#{bit64_reg}\\App2")
      .and_return([{ name: 'DisplayName', value: 'App2', blah: 'blah' }])
    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_values).with("#{bit64_reg}\\App3")
      .and_return([{ name: 'DisplayVersion', value: '3', blah: 'blah' }])

    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_values).with("#{bit32_reg}\\App4").and_return(
        [
          { name: 'Pants', data: 2 },
          { name: 'DisplayName', data: 'App 4' },
          { name: 'DisplayVersion', data: '4.0.0.1' }
        ]
      )
    allow_any_instance_of(Chef::DSL::RegistryHelper)
      .to receive(:registry_get_values).with("#{bit32_reg}\\App5").and_return(
        [
          { name: 'Pants', data: 2 },
          { name: 'DisplayName', data: 'App 5' },
          { name: 'DisplayVersion', data: '5.0.0.1' }
        ]
      )
    if installed_version
      allow_any_instance_of(Chef::DSL::RegistryHelper)
        .to receive(:registry_get_values).with("#{bit32_reg}\\ChefDkApp")
        .and_return(
          [
            { name: 'Pants', data: 2 },
            { name: 'DisplayName',
              data: "Chef Development Kit v#{installed_version}" },
            { name: 'DisplayVersion', data: "#{installed_version}.1" }
          ]
        )
    end
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

      [
        'the default source (:direct)',
        'a custom source'
      ].each do |c|
        context c do
          include_context description

          context 'the latest version already installed' do
            include_context description

            it 'removes the Chef-DK Windows package' do
              expect(chef_run).to remove_package('Chef Development Kit v1.2.3')
            end

            it 'deletes the Chef-DK AppData directory' do
              d = File.expand_path('~/AppData/Local/chefdk')
              expect(chef_run).to delete_directory(d).with(recursive: true)
            end
          end

          context 'not already installed' do
            it 'does not remove the Chef-DK Windows package' do
              expect(chef_run)
                .to_not remove_package('Chef Development Kit v1.2.3')
            end

            it 'does not delete the Chef-DK AppData directory' do
              d = File.expand_path('~/AppData/Local/chefdk')
              expect(chef_run).to_not delete_directory(d)
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
