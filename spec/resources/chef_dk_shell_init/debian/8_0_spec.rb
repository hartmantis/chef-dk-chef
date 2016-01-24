require_relative '../../../spec_helper'

describe 'resource_chef_dk_shell_init::debian::8_0' do
  let(:user) { nil }
  let(:action) { nil }
  let(:file_edit) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'chef_dk_shell_init',
      platform: 'debian',
      version: '8.0'
    ) do |node|
      node.set['chef_dk']['shell_init_user'] = user
    end
  end
  let(:converge) { runner.converge("chef_dk_shell_init_test::#{action}") }
  let(:chef_run) { converge }

  before(:each) do
    allow(Chef::Util::FileEdit).to receive(:new).and_return(file_edit)
  end

  context 'the default action (:enable)' do
    let(:action) { :default }

    context 'the default user property (nil)' do
      let(:user) { nil }

      context 'not already enabled' do
        let(:file_edit) do
          double(insert_line_if_no_match: true, write_file: true)
        end

        it 'writes to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new).with('/etc/bash.bashrc')
          expect(file_edit).to receive(:insert_line_if_no_match)
            .with(/^eval "\$\(chef shell-init bash\)"$/,
                  'eval "$(chef shell-init bash)"')
          expect(file_edit).to receive(:write_file)
          chef_run
        end
      end

      context 'already enabled' do
        let(:file_edit) do
          double(insert_line_if_no_match: false, write_file: false)
        end

        it 'does not write to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new).with('/etc/bash.bashrc')
          expect(file_edit).to receive(:insert_line_if_no_match)
            .with(/^eval "\$\(chef shell-init bash\)"$/,
                  'eval "$(chef shell-init bash)"')
          expect(file_edit).to_not receive(:write_file)
          chef_run
        end
      end
    end

    context 'a specified user property' do
      let(:user) { 'fauxhai' }

      context 'not already enabled' do
        let(:file_edit) do
          double(insert_line_if_no_match: true, write_file: true)
        end

        it 'writes to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new)
            .with('/home/fauxhai/.bashrc')
          expect(file_edit).to receive(:insert_line_if_no_match)
            .with(/^eval "\$\(chef shell-init bash\)"$/,
                  'eval "$(chef shell-init bash)"')
          expect(file_edit).to receive(:write_file)
          chef_run
        end
      end

      context 'already enabled' do
        let(:file_edit) do
          double(insert_line_if_no_match: false, write_file: false)
        end

        it 'does not write to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new)
            .with('/home/fauxhai/.bashrc')
          expect(file_edit).to receive(:insert_line_if_no_match)
            .with(/^eval "\$\(chef shell-init bash\)"$/,
                  'eval "$(chef shell-init bash)"')
          expect(file_edit).to_not receive(:write_file)
          chef_run
        end
      end
    end
  end

  context 'the :disable action' do
    let(:action) { :disable }

    context 'the default user property (nil)' do
      let(:user) { nil }

      context 'already enabled' do
        let(:file_edit) do
          double(search_file_delete_line: true, write_file: true)
        end

        it 'writes to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new).with('/etc/bash.bashrc')
          expect(file_edit).to receive(:search_file_delete_line)
            .with(/^eval "\$\(chef shell-init bash\)"$/)
          expect(file_edit).to receive(:write_file)
          chef_run
        end
      end

      context 'not already enabled' do
        let(:file_edit) do
          double(search_file_delete_line: false, write_file: false)
        end

        it 'does not write to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new).with('/etc/bash.bashrc')
          expect(file_edit).to receive(:search_file_delete_line)
            .with(/^eval "\$\(chef shell-init bash\)"$/)
          expect(file_edit).to_not receive(:write_file)
          chef_run
        end
      end
    end

    context 'a specified user property' do
      let(:user) { 'fauxhai' }

      context 'already enabled' do
        let(:file_edit) do
          double(search_file_delete_line: true, write_file: true)
        end

        it 'writes to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new)
            .with('/home/fauxhai/.bashrc')
          expect(file_edit).to receive(:search_file_delete_line)
            .with(/^eval "\$\(chef shell-init bash\)"$/)
          expect(file_edit).to receive(:write_file)
          chef_run
        end
      end

      context 'not enabled' do
        let(:file_edit) do
          double(insert_line_if_no_match: false, write_file: false)
        end

        it 'does not write to the global bashrc' do
          expect(Chef::Util::FileEdit).to receive(:new)
            .with('/home/fauxhai/.bashrc')
          expect(file_edit).to receive(:search_file_delete_line)
            .with(/^eval "\$\(chef shell-init bash\)"$/)
          expect(file_edit).to_not receive(:write_file)
          chef_run
        end
      end
    end
  end
end
