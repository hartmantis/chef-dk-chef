require_relative '../resources'

describe 'resources::chef_dk_shell_init' do
  include_context 'resources'

  let(:resource) { 'chef_dk_shell_init' }
  %i(user).each { |p| let(p) { nil } }
  let(:properties) { { user: user } }
  let(:name) { 'default' }

  let(:root_bashrc) { nil }
  let(:user_bashrc) { nil }
  let(:enabled?) { false }

  before(:each) do
    content = <<-EOH.gsub(/^ +/, '')
      # Here is a
      # bashrc
    EOH
    content << 'eval "$(chef shell-init bash)"' if enabled?
    allow(File).to receive(:read).with(root_bashrc).and_return(content)
    allow(File).to receive(:read).with(user_bashrc).and_return(content)
  end

  shared_examples_for 'any supported platform' do
    context 'the default action (:enable)' do
      context 'the default user property (nil)' do
        context 'disabled' do
          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
              eval "$(chef shell-init bash)"
            EOH
            expect(chef_run).to create_file(root_bashrc).with(content: expected)
          end
        end

        context 'already enabled' do
          let(:enabled?) { true }

          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
              eval "$(chef shell-init bash)"
            EOH
            expect(chef_run).to create_file(root_bashrc).with(content: expected)
          end
        end
      end

      context 'an overridden user property' do
        let(:user) { 'fauxhai' }

        context 'disabled' do
          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
              eval "$(chef shell-init bash)"
            EOH
            expect(chef_run).to create_file(user_bashrc).with(content: expected)
          end
        end

        context 'already enabled' do
          let(:enabled?) { true }

          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
              eval "$(chef shell-init bash)"
            EOH
            expect(chef_run).to create_file(user_bashrc).with(content: expected)
          end
        end
      end
    end

    context 'the :disable action' do
      let(:action) { :disable }

      context 'the default user property (nil)' do
        context 'enabled' do
          let(:enabled?) { true }

          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
            EOH
            expect(chef_run).to create_file(root_bashrc).with(content: expected)
          end
        end

        context 'already disabled' do
          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
            EOH
            expect(chef_run).to create_file(root_bashrc).with(content: expected)
          end
        end
      end

      context 'an overridden user property' do
        let(:user) { 'fauxhai' }

        context 'enabled' do
          let(:enabled?) { true }

          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
            EOH
            expect(chef_run).to create_file(user_bashrc).with(content: expected)
          end
        end

        context 'already disabled' do
          it 'writes the expected content to the bashrc' do
            expected = <<-EOH.gsub(/^ +/, '')
              # Here is a
              # bashrc
            EOH
            expect(chef_run).to create_file(user_bashrc).with(content: expected)
          end
        end
      end
    end
  end
end
