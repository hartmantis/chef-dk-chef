# frozen_string_literal: true
require_relative '../resources'
require_relative '../../libraries/helpers'

shared_context 'resources::chef_dk' do
  include_context 'resources'

  let(:resource) { 'chef_dk' }
  %i(version channel source checksum gems shell_users).each do |p|
    let(p) { nil }
  end
  let(:properties) do
    {
      version: version,
      channel: channel,
      source: source,
      checksum: checksum,
      gems: gems,
      shell_users: shell_users
    }
  end
  let(:name) { 'default' }

  shared_examples_for 'any platform' do
    context 'the default action (:create)' do
      context 'all default properties' do
        it 'installs the chef_dk_app' do
          expect(chef_run).to install_chef_dk_app(name)
        end
      end

      context 'an overridden version property' do
        let(:version) { '1.2.3' }

        it 'passes the version on to the underlying chef_dk_app' do
          expect(chef_run).to install_chef_dk_app(name).with(version: '1.2.3')
        end
      end

      context 'an overridden channel property' do
        let(:channel) { :current }

        it 'passes the channel on to the underlying chef_dk_app' do
          expect(chef_run).to install_chef_dk_app(name)
            .with(channel: :current)
        end
      end

      context 'an overridden source property' do
        let(:source) { :repo }

        it 'passes the source on to the underlying chef_dk_app' do
          expect(chef_run).to install_chef_dk_app(name).with(source: :repo)
        end
      end

      context 'an overridden checksum property' do
        let(:checksum) { 'abc123' }

        it 'passes the checksum on to the underlying chef_dk_app' do
          expect(chef_run).to install_chef_dk_app(name)
            .with(checksum: 'abc123')
        end
      end

      context 'an overridden gems property' do
        let(:gems) { %w(gem1 test2) }

        it 'installs the desired gems' do
          %w(gem1 test2).each do |g|
            expect(chef_run).to install_chef_dk_gem(g)
          end
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

    context 'the :remove action' do
      let(:action) { :remove }

      it 'disables the shell_init for every system user' do
        unless platform == 'windows'
          cr = chef_run
          cr.node['etc']['passwd'].keys.each do |user|
            expect(cr).to disable_chef_dk_shell_init(user)
          end
        end
      end

      it 'removes the chef_dk_app' do
        expect(chef_run).to remove_chef_dk_app(name)
      end
    end
  end
end
