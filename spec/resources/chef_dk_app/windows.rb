require_relative '../chef_dk_app'

shared_context 'resources::chef_dk_app::windows' do
  include_context 'resources::chef_dk_app'

  shared_examples_for 'any Windows platform' do
    context 'the default action (:install)' do
      include_context description

      context 'the default source (:direct)' do
        include_context description

        shared_examples_for 'any property set' do
          it 'installs the correct Chef-DK package' do
            expect(chef_run).to install_package('Chef Development Kit').with(
              source: "http://example.com/#{channel || 'stable'}/chefdk",
              checksum: '1234'
            )
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
            pending
            expect(false).to eq(true)
          end
        end
      end

      context 'a custom source' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'installs the correct Chef-DK package' do
            expect(chef_run).to install_package('Chef Development Kit').with(
              source: 'https://example.biz/cdk',
              checksum: '12345'
            )
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

          it 'removes the Chef-DK Windows package' do
            expect(chef_run).to remove_package('Chef Development Kit')
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
