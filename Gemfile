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
  # TODO: guard-foodcritic has a dep conflict with Berkshelf 3
  # gem 'guard-foodcritic'
  gem 'rspec', '>= 3'
  gem 'chefspec', '>= 4'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'coveralls'
  gem 'fauxhai'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean', '>= 0.8.0'
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
end
