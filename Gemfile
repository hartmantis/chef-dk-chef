# Encoding: UTF-8

source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'yard-chef'
  gem 'guard'
  gem 'cane'
  gem 'countloc'
  gem 'rubocop'
  gem 'foodcritic'
  # TODO: guard-foodcritic has a dep conflict with Berkshelf 3
  # gem 'guard-foodcritic'
  gem 'rspec'
  gem 'chefspec'
  gem 'guard-rspec'
  gem 'serverspec'
  gem 'fauxhai'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean',
      # TODO: Pending the merge and release of
      # https://github.com/test-kitchen/kitchen-digitalocean/pull/16
      github: 'RoboticCheese/kitchen-digitalocean',
      branch: 'roboticcheese/swap-centos-6.5-image-id'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
  gem 'guard-kitchen'
  gem 'cucumber'
end

gem 'chef'
gem 'berkshelf'
