# Encoding: UTF-8

attrs = node['chef_dk_resource_test']

send(attrs['resource'], attrs['name']) do
  attrs.each do |k, v|
    next if %w(resource name).include?(k.to_s)
    send(k, v)
  end
end
