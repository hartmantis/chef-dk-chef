# configure a gem using chefdk gemset

def whyrun_supported?
  true
end

action :install do
  Chef::Log.debug "Installing chef gem #{new_resource.name}"
  execute "chef exec gem install \
    #{new_resource.name} #{'--version' unless new_resource.version.nil?}\
    #{new_resource.version unless new_resource.version.nil?}" do
    user new_resource.user
    environment(
      'HOME' => Dir.home(new_resource.user),
      'USER' => new_resource.user)
    cwd Dir.home(new_resource.user)
    not_if(::File.exist?("#{Dir.home(new_resource.user)}/.chefdk/gem/ruby/\
      2.1.0/gems/#{new_resource.name}-\
      #{new_resource.version unless new_resource.version.nil?}*"))
  end
  new_resource.updated_by_last_action(true)
end

action :remove do
  Chef::Log.debug "Uninstalling chef gem #{new_resource.name}"
  execute "chef exec gem uninstall #{'-a' if new_resource.version.nil?} \
    #{new_resource.name} #{'--version' unless new_resource.version.nil?} \
    #{new_resource.version unless new_resource.version.nil?}" do
    user new_resource.user
    cwd Dir.home(new_resource.user)
    environment(
      'HOME' => Dir.home(new_resource.user),
      'USER' => new_resource.user)
  end
  new_resource.updated_by_last_action(true)
end
