require_relative '../resources'
require_relative '../../libraries/helpers'

shared_context 'resources::chef_dk' do
  include_context 'resources'

  let(:resource) { 'chef_dk' }
  %i(gems shell_users).each { |p| let(p) { nil } }
  let(:properties) { { gems: gems, shell_users: shell_users } }
  let(:name) { 'default' }

  shared_examples_for 'any platform' do
    context 'the default action (:create)' do
      context 'the default source (:direct)' do
        let(:source) { nil }

        context 'all default properties' do
          it 'installs the chef_dk_app' do
            expect(chef_run).to install_chef_dk_app(name)
          end

          it 'disables the chef_dk_shell_init' do
            expect(chef_run).to disable_chef_dk_shell_init(name)
          end
        end

        context 'an overridden gems property' do
          let(:gems) { %w(gem1 test2) }

          it 'installs the desired gems' do
            %w(gem1 test2).each do |g|
              expect(chef_run).to install_chef_dk_gem(g)
          end
        end

        context 'an overridden shell_users property' do
          let(:shell_users) { %w(me them) }

          it 'enables shell_init for the desired users' do
            %w(me them).each do |u|
              expect(chef_run).to enable_chef_dk_shell_init(u)
            end
          end
        end
      end
    end

    context 'the :remove action' do
      let(:action) { :remove }

      it 'disables the chef_dk_shell_init' do
        expect(chef_run).to disable_chef_dk_shell_init(name)
      end

      it 'removes the chef_dk_app' do
        expect(chef_run).to remove_chef_dk_app(name)
      end
    end
  end
end
