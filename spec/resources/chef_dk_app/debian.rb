# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::debian' do
  include_context 'resources::chef_dk_app'

  before(:each) do
    allow_any_instance_of(Chef::Provider::Package::Dpkg)
      .to receive(:load_current_resource)
      .and_return(double(version: [installed_version]))
  end

  shared_examples_for 'any Debian platform' do
    it_behaves_like 'any platform'

    context 'the default action (:install)' do
      include_context description

      context 'the default source (:direct)' do
        include_context description

        shared_examples_for 'installs Chef-DK' do
          it 'downloads the correct Chef-DK' do
            expect(chef_run).to create_remote_file('/tmp/cache/chefdk')
              .with(source: "http://example.com/#{channel || 'stable'}/chefdk",
                    checksum: '1234')
          end

          it 'installs the downloaded package' do
            expect(chef_run).to install_dpkg_package('/tmp/cache/chefdk')
          end
        end

        shared_examples_for 'does not install Chef-DK' do
          it 'does not download the correct Chef-DK' do
            expect(chef_run).to_not create_remote_file('/tmp/cache/chefdk')
          end

          it 'does not install the downloaded package' do
            expect(chef_run).to_not install_dpkg_package('/tmp/cache/chefdk')
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

        shared_examples_for 'any property set' do
          it 'ensures apt-transport-https is installed' do
            expect(chef_run).to install_package('apt-transport-https')
          end

          it 'configures the Chef APT repo' do
            expect(chef_run).to include_recipe(
              "apt-chef::#{channel || 'stable'}"
            )
          end

          it 'installs the chefdk package' do
            expect(chef_run).to install_package('chefdk').with(version: version)
          end
        end

        [
          'all default properties',
          'an overridden channel property',
          'an overridden version property'
        ].each do |c|
          context c do
            include_context description

            it_behaves_like 'any property set'
          end
        end
      end

      context 'a custom source' do
        include_context description

        shared_examples_for 'does not install Chef-DK' do
          it 'does not download the correct Chef-DK' do
            expect(chef_run).to_not create_remote_file('/tmp/cache/chefdk')
          end

          it 'does not install the downloaded package' do
            expect(chef_run).to_not install_dpkg_package('/tmp/cache/chefdk')
          end
        end

        context 'all default properties' do
          include_context description

          it 'downloads the correct Chef-DK' do
            expect(chef_run).to create_remote_file('/tmp/cache/cdk')
              .with(source: 'https://example.biz/cdk', checksum: '12345')
          end

          it 'installs the downloaded package' do
            expect(chef_run).to install_dpkg_package('/tmp/cache/cdk')
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
          it 'downloads the correct Chef-DK' do
            expect(chef_run).to create_remote_file('/tmp/cache/chefdk')
              .with(source: "http://example.com/#{channel || 'stable'}/chefdk",
                    checksum: '1234')
          end

          it 'installs the downloaded package' do
            expect(chef_run).to install_dpkg_package('/tmp/cache/chefdk')
          end
        end

        shared_examples_for 'does not upgrade Chef-DK' do
          it 'does not download the correct Chef-DK' do
            expect(chef_run).to_not create_remote_file('/tmp/cache/chefdk')
          end

          it 'does not install the downloaded package' do
            expect(chef_run).to_not install_dpkg_package('/tmp/cache/chefdk')
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

        shared_examples_for 'any property set' do
          it 'ensures apt-transport-https is installed' do
            expect(chef_run).to install_package('apt-transport-https')
          end

          it 'configures the Chef APT repo' do
            expect(chef_run).to include_recipe(
              "apt-chef::#{channel || 'stable'}"
            )
          end

          it 'upgrades the chefdk package' do
            expect(chef_run).to upgrade_package('chefdk').with(version: version)
          end
        end

        [
          'all default properties',
          'an overridden channel property'
        ].each do |c|
          context c do
            include_context description

            it_behaves_like 'any property set'
          end
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'purges the package' do
          expect(chef_run).to purge_package('chefdk')
        end
      end

      [
        'the default source (:direct)',
        'the :repo source',
        'a custom source'
      ].each do |c|
        context c do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end
  end
end
