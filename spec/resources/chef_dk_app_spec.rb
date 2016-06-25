require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe 'chef_dk_app' do
  let(:resource) { 'chef_dk_app' }
  let(:name) { 'default' }
  %i(platform platform_version version channel source action).each do |p|
    let(p) { nil }
  end
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: resource, platform: platform, version: platform_version
    ) do |node|
      %i(resource name version channel source action).each do |p|
        node.set['chef_dk_resource_test'][p] = send(p) unless send(p).nil?
      end
    end
  end
  let(:converge) { runner.converge('chef_dk_resource_test') }

  context 'the default action (:install)' do
    let(:action) { nil }

    before(:each) do
      allow(Kernel).to receive(:load).and_call_original
      allow(Kernel).to receive(:load)
        .with(%r{chef-dk/libraries/helpers\.rb}).and_return(true)
      allow(ChefDk::Helpers).to receive(:metadata_for).with(
        channel: channel || :stable,
        version: version || 'latest',
        platform: platform,
        platform_version: platform_version,
        machine: 'x86_64'
      ).and_return(
        sha1: 'abcd',
        sha256: '1234',
        url: "http://example.com/#{channel}chefdk",
        version: version || '1.2.3'
      )
    end

    context 'the default source (:direct)' do
      let(:source) { nil }

      shared_examples_for 'Debian platforms' do
        it 'downloads the correct Chef-DK' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/chefdk"
          ).with(source: 'http://example.com/stable/chefdk', checksum: '1234')
        end

        it 'installs the downloaded package' do
          expect(chef_run).to install_dpkg_package(
            "#{Chef::Config[:file_cache_path]}/chefdk"
          )
        end
      end

      shared_examples_for 'RHEL platforms' do
        it 'downloads the correct Chef-DK' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/chefdk"
          ).with(source: 'http://example.com/stable/chefdk', checksum: '1234')
        end

        it 'installs the downloaded package' do
          expect(chef_run).to install_rpm_package(
            "#{Chef::Config[:file_cache_path]}/chefdk"
          )
        end
      end

      context 'all default properties' do
        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }

            it 'installs the Chef-DK package' do
              expect(chef_run).to install_dmg_package('Chef Development Kit')
                .with(app: 'chefdk.dmg',
                      volumes_dir: 'Chef Development Kit',
                      source: 'http://example.com/stable/chefdk',
                      type: 'pkg',
                      package_id: 'com.getchef.pkg.chefdk',
                      checksum: '1234')
            end
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }

            it 'installs the Chef-DK package' do
              expect(chef_run).to install_windows_package(
                'Chef Development Kit'
              ).with(source: 'http://example.com/stable/chefdk',
                     checksum: '1234')
            end
          end
        end
      end

      context 'an overridden channel property' do
        let(:channel) { :current }

        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }

            it_behaves_like 'RHEL platforms'
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }
          end
        end
      end

      context 'an overridden version property' do
        let(:version) { '4.5.6' }

        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }
          end
        end
      end
    end

    context 'the :repo source' do
      let(:source) { :repo }

      shared_examples_for 'Debian platforms' do
        it 'configures the Chef APT repo' do
          expect(chef_run).to include_recipe("apt-chef::#{channel || 'stable'}")
        end

        it 'installs the chefdk package' do
          expect(chef_run).to install_package('chefdk').with(version: version)
        end
      end

      context 'all other default properties' do
        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }
          end
        end
      end

      context 'an overridden version property' do
        let(:version) { '4.5.6' }

        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }
          end
        end
      end
    end

    context 'a custom source' do
      let(:source) { 'https://example.biz/cdk' }

      shared_examples_for 'Debian platforms' do
        it 'downloads the correct Chef-DK' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/cdk"
          ).with(source: 'https://example.biz/cdk', checksum: '1234')
        end

        it 'installs the downloaded package' do
          expect(chef_run).to install_dpkg_package(
            "#{Chef::Config[:file_cache_path]}/cdk"
          )
        end
      end

      context 'all other default properties' do
        context 'Ubuntu' do
          let(:platform) { 'ubuntu' }

          context '16.04' do
            let(:platform_version) { '16.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end

          context '14.04' do
            let(:platform_version) { '14.04' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'Debian' do
          let(:platform) { 'debian' }

          context '8.4' do
            let(:platform_version) { '8.4' }
            cached(:chef_run) { converge }

            it_behaves_like 'Debian platforms'
          end
        end

        context 'CentOS' do
          let(:platform) { 'centos' }

          context '7.0' do
            let(:platform_version) { '7.0' }
            cached(:chef_run) { converge }
          end
        end

        context 'Red Hat' do
          let(:platform) { 'redhat' }

          context '7.1' do
            let(:platform_version) { '7.1' }
            cached(:chef_run) { converge }
          end
        end

        context 'Fedora' do
          let(:platform) { 'fedora' }

          context '23' do
            let(:platform_version) { '23' }
            cached(:chef_run) { converge }
          end
        end

        context 'MacOS' do
          let(:platform) { 'mac_os_x' }

          context '10.10' do
            let(:platform_version) { '10.10' }
            cached(:chef_run) { converge }
          end
        end

        context 'Windows' do
          let(:platform) { 'windows' }

          context '10' do
            let(:platform_version) { '10' }
            cached(:chef_run) { converge }
          end
        end
      end

      context 'an overridden version property' do
        let(:version) { '4.5.6' }

        shared_examples_for 'any platform' do
          it 'raises an error' do
            pending
            e = Chef::Exceptions::ValidationFailed
            expect { chef_run }.to raise_error(e)
          end
        end

        {
          'Ubuntu' => %w(16.04 14.04),
          'Debian' => %w(8.4),
          'CentOS' => %w(7.0),
          'RedHat' => %w(7.1),
          'Fedora' => %w(23),
          'Mac_OS_X' => %w(10.10),
          'Windows' => %w(10)
        }.each do |p, pvs|
          context p do
            let(:platform) { p.downcase }

            pvs.each do |pv|
              context pv do
                let(:platform_version) { pv }
                cached(:chef_run) { converge }

                it_behaves_like 'any platform'
              end
            end
          end
        end
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }

    shared_examples_for 'Debian platforms' do
      it 'removes the package' do
        expect(chef_run).to remove_package('chefdk')
      end
    end

    context 'the default source (:direct)' do
      context 'Ubuntu' do
        let(:platform) { 'ubuntu' }

        context '16.04' do
          let(:platform_version) { '16.04' }
          cached(:chef_run) { converge }

          it_behaves_like 'Debian platforms'
        end

        context '14.04' do
          let(:platform_version) { '14.04' }
          cached(:chef_run) { converge }
  
          it_behaves_like 'Debian platforms'
        end
      end

      context 'Debian' do
        let(:platform) { 'debian' }
  
        context '8.4' do
          let(:platform_version) { '8.4' }
          cached(:chef_run) { converge }
  
          it_behaves_like 'Debian platforms'
        end
      end

      context 'CentOS' do
        let(:platform) { 'centos' }

        context '7.0' do
          let(:platform_version) { '7.0' }
          cached(:chef_run) { converge }
        end
      end

      context 'Red Hat' do
        let(:platform) { 'redhat' }

        context '7.1' do
          let(:platform_version) { '7.1' }
          cached(:chef_run) { converge }
        end
      end

      context 'Fedora' do
        let(:platform) { 'fedora' }

        context '23' do
          let(:platform_version) { '23' }
          cached(:chef_run) { converge }
        end
      end

      context 'MacOS' do
        let(:platform) { 'mac_os_x' }

        context '10.10' do
          let(:platform_version) { '10.10' }
          cached(:chef_run) { converge }
        end
      end

      context 'Windows' do
        let(:platform) { 'windows' }

        context '10' do
          let(:platform_version) { '10' }
          cached(:chef_run) { converge }

          it 'removes the Windows package' do
            p = 'Chef Development Kit'
            expect(chef_run).to remove_windows_package(p)
          end
        end
      end
    end

    context 'the :repo source' do
      context 'Ubuntu' do
        let(:platform) { 'ubuntu' }
  
        context '16.04' do
          let(:platform_version) { '16.04' }
          cached(:chef_run) { converge }
  
          it_behaves_like 'Debian platforms'
        end
  
        context '14.04' do
          let(:platform_version) { '14.04' }
          cached(:chef_run) { converge }
  
          it_behaves_like 'Debian platforms'
        end
      end
  
      context 'Debian' do
        let(:platform) { 'debian' }
  
        context '8.4' do
          let(:platform_version) { '8.4' }
          cached(:chef_run) { converge }
  
          it_behaves_like 'Debian platforms'
        end
      end
  
      context 'CentOS' do
        let(:platform) { 'centos' }
  
        context '7.0' do
          let(:platform_version) { '7.0' }
          cached(:chef_run) { converge }
        end
      end
  
      context 'Red Hat' do
        let(:platform) { 'redhat' }
  
        context '7.1' do
          let(:platform_version) { '7.1' }
          cached(:chef_run) { converge }
        end
      end
  
      context 'Fedora' do
        let(:platform) { 'fedora' }
  
        context '23' do
          let(:platform_version) { '23' }
          cached(:chef_run) { converge }
        end
      end
  
      context 'MacOS' do
        let(:platform) { 'mac_os_x' }
  
        context '10.10' do
          let(:platform_version) { '10.10' }
          cached(:chef_run) { converge }
        end
      end
  
      context 'Windows' do
        let(:platform) { 'windows' }
  
        context '10' do
          let(:platform_version) { '10' }
          cached(:chef_run) { converge }
        end
      end
    end
  end
end
