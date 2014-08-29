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
  gem 'rspec'
  gem 'chefspec'
  gem 'fauxhai'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean', '>= 0.7.1'
  gem 'kitchen-vagrant'
end

group :integration do
  gem 'serverspec'
  gem 'cucumber'
end

gem 'chef', '>= 11'
gem 'berkshelf'
gem 'stove'
