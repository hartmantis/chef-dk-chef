# Encoding: UTF-8

require 'serverspec'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  set :os, family: 'windows'
  set :backend, :cmd
else
  set :backend, :exec
end
