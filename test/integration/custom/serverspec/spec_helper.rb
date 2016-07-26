# encoding: utf-8
# frozen_string_literal: true

require 'serverspec'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  set :os, family: 'windows'
  set :backend, :cmd
else
  set :backend, :exec
end
