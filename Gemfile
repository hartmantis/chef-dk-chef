# Encoding: UTF-8

source 'https://rubygems.org'

group :development do
  gem 'yard-chef'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-kitchen'
end

group :test do
  gem 'rake'
  gem 'cane'
  gem 'countloc'
  gem 'rubocop'
  gem 'foodcritic'
  gem 'guard-foodcritic'
  gem 'rspec', '>= 3'
  gem 'chefspec', '>= 4'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'coveralls'
  gem 'fauxhai'
  # TODO: Can unpin TK RC when Windows support final version is released
  gem 'test-kitchen', '~> 1.4.0.rc'
  gem 'winrm-transport'
  gem 'kitchen-ec2'
  gem 'kitchen-vagrant'
end

group :integration do
  gem 'serverspec', '>= 2'
  gem 'cucumber'
end

group :deploy do
  gem 'stove'
end

group :production do
  gem 'chef', '>= 11'
  gem 'berkshelf', '>= 3'
  gem 'omnijack', '~> 1.0'
end
