# Encoding: UTF-8

require 'serverspec'

if RUBY_PLATFORM.match(/mswin|mingw32|windows/)
  set :os, family: 'windows'
  set :backend, :cmd
else
  set :backend, :exec
end
