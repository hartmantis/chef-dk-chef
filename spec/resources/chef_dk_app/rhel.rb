# encoding: utf-8
# frozen_string_literal: true

require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::rhel' do
  include_context 'resources::chef_dk_app'

  before(:each) do
    allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out)
      .with('rpm -q --info chefdk').and_return(
        double(exitstatus: installed_version.nil? ? 1 : 0,
               stdout: "Name        : chefdk\nVersion     : "\
                       "#{installed_version}\nRelease     : 1.el7\n")
      )
  end

  shared_examples_for 'any RHEL platform' do
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
            expect(chef_run).to install_rpm_package('/tmp/cache/chefdk')
          end
        end

        shared_examples_for 'does not install Chef-DK' do
          it 'does not download the correct Chef-DK' do
            expect(chef_run).to_not create_remote_file('/tmp/cache/chefdk')
          end

          it 'does not install the downloaded package' do
            expect(chef_run).to_not install_rpm_package('/tmp/cache/chefdk')
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
          it 'configures the Chef YUM repo' do
            expect(chef_run).to include_recipe(
              "yum-chef::#{channel || 'stable'}"
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

        context 'all default properties' do
          include_context description

          it 'downloads the correct Chef-DK' do
            expect(chef_run).to create_remote_file('/tmp/cache/cdk')
              .with(source: 'https://example.biz/cdk', checksum: '12345')
          end

          it 'installs the downloaded package' do
            expect(chef_run).to install_rpm_package('/tmp/cache/cdk')
          end
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
            expect(chef_run).to install_rpm_package('/tmp/cache/chefdk')
          end
        end

        shared_examples_for 'does not upgrade Chef-DK' do
          it 'does not download the correct Chef-DK' do
            expect(chef_run).to_not create_remote_file('/tmp/cache/chefdk')
          end

          it 'does not install the downloaded package' do
            expect(chef_run).to_not install_rpm_package('/tmp/cache/chefdk')
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
          it 'configures the Chef YUM repo' do
            expect(chef_run).to include_recipe(
              "yum-chef::#{channel || 'stable'}"
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
        it 'removes the package' do
          expect(chef_run).to remove_rpm_package('chefdk')
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
