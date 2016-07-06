require_relative '../resources'
require_relative '../../libraries/helpers'

shared_context 'resources::chef_dk' do
  include_context 'resources'

  let(:resource) { 'chef_dk' }
  %i(global_shell_init).each { |p| let(p) { nil } }
  let(:properties) { { global_shell_init: global_shell_init } }
  let(:name) { 'default' }

  shared_examples_for 'any platform' do
    context 'the default action (:create)' do

      context 'the default source (:direct)' do
        let(:source) { nil }

        context 'all default properties' do
          cached(:chef_run) { converge }

          it 'installs the chef_dk_app' do
            expect(chef_run).to install_chef_dk_app(name)
          end

          it 'disables the chef_dk_shell_init' do
            expect(chef_run).to disable_chef_dk_shell_init(name)
          end
        end

        context 'an overridden global_shell_init property' do
          let(:global_shell_init) { true }
          cached(:chef_run) { converge }

          it 'installs the chef_dk_app' do
            expect(chef_run).to install_chef_dk_app(name)
          end

          it 'enables the chef_dk_shell_init' do
            expect(chef_run).to enable_chef_dk_shell_init(name)
          end
        end
      end
    end

    context 'the :remove action' do
      let(:action) { :remove }
      cached(:chef_run) { converge }

      it 'disables the chef_dk_shell_init' do
        expect(chef_run).to disable_chef_dk_shell_init(name)
      end

      it 'removes the chef_dk_app' do
        expect(chef_run).to remove_chef_dk_app(name)
      end
    end
  end
end
