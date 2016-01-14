property :version, String, default: node['chef_dk']['version']
property :package_url, [String, nil], default: node['chef_dk']['package_url']
property :global_shell_init, [TrueClass, FalseClass], default: node['chef_dk']['global_shell_init']
property :prerelease, [TrueClass, FalseClass], default: false
property :nightlies, [TrueClass, FalseClass], default: false

resource_name :chef_dk

default_action :install

# Set some globals
BASHRC_FILE = node['platform_family'].eql?('debian') ? '/etc/bash.bashrc' : '/etc/bashrc'
SHELL_INIT_LINE = 'eval "$(chef shell-init bash)"'
SHELL_INIT_MATCHER = /^eval "\$\(chef shell-init bash\)"$/
DOWNLOAD_PATH = ::File.join(Chef::Config['file_cache_path'],'chefdk')

action :remove do
  package 'chefdk' do
    action :remove
  end
  ruby_block 'global_shell_init' do
    block do
      bashrc = Chef::Util::FileEdit.new(BASHRC_FILE)
      bashrc.search_file_delete_line(SHELL_INIT_MATCHER)
      bashrc.write_file
    end
    only_if { node['platform'] != 'windows' && node['chef_dk']['global_shell_init'] }
  end
end

action :install do
  # Need omnijack to lookup chefdk info
  chef_gem 'omnijack' do
    action :nothing
    compile_time true
  end.run_action(:install)
  Gem.clear_paths
  require 'omnijack'

  # Get chefdk pkf info
  chef_dk_metadata = Omnijack::Project::ChefDk.new(
             platform: node['platform'],
             platform_version: node['platform_version'],
             machine_arch: node['kernel']['machine'],
             version: node['chef_dk']['version'],
             prerelease: node['chef_dk']['prerelease'],
             nightlies: node['chef_dk']['nightlies']
  ).metadata

  directory DOWNLOAD_PATH do
    action :create
  end

  # Download the chefdk package and run the install and pruner
  remote_file chef_dk_metadata.filename do
    path ::File.join(DOWNLOAD_PATH,chef_dk_metadata.filename)
    source chef_dk_metadata.url
    checksum chef_dk_metadata.sha256
    notifies :upgrade, 'package[chefdk]'
    notifies :run, 'ruby_block[rm_old_pkg_files]'
  end

  # This will keep the pkg files pruned
  ruby_block 'rm_old_pkg_files' do
    block do
      ::Dir.glob(DOWNLOAD_PATH + '/*').each do |file|
        ::File.delete(file) unless ::File.basename(file).eql?(chef_dk_metadata.filename)
      end
    end
  end

  package 'chefdk' do
    case node['platform_family']
    when 'debian'
      provider Chef::Provider::Package::Dpkg
    when 'rhel'
      provider Chef::Provider::Package::Rpm
      allow_downgrade true
    end
    version chef_dk_metadata.version
    source ::File.join(DOWNLOAD_PATH,chef_dk_metadata.filename)
    action :nothing
  end

  ruby_block 'global_shell_init' do
    block do
      bashrc = Chef::Util::FileEdit.new(BASHRC_FILE)
      bashrc.insert_line_if_no_match(SHELL_INIT_MATCHER,SHELL_INIT_LINE)
      bashrc.write_file
    end
    only_if { node['platform'] != 'windows' && node['chef_dk']['global_shell_init'] }
  end
end
