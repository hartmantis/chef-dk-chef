# Encoding: UTF-8

require 'rubygems'
require 'English'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'

module ChefDk
  # Helper methods for uploading and deleting DigitalOcean build keys
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  class Helpers
    def self.compute
      Fog::Compute.new(provider: 'DigitalOcean',
                       digitalocean_client_id: ENV['DIGITALOCEAN_CLIENT_ID'],
                       digitalocean_api_key: ENV['DIGITALOCEAN_API_KEY'])
    end

    def self.key_name
      "chef-dk-chef-kitchen-#{ENV['TRAVIS_BUILD_NUMBER']}"
    end

    def self.private_key_file
      File.expand_path(ENV['DIGITALOCEAN_SSH_KEY_FILE'])
    end

    def self.public_key_file
      "#{private_key_file}.pub"
    end

    def self.ssh_key_ids
      compute.ssh_keys.map do |k|
        k.id if k.name == key_name
      end.compact.join(', ')
    end

    def self.upload_key_to_digitalocean!
      unless compute.ssh_keys.index { |k| k.name == key_name }
        compute.ssh_keys.create(name: key_name,
                                ssh_pub_key: File.open(public_key_file).read)
      end
      ssh_key_ids
    end

    def self.delete_key_from_digitalocean!
      compute.ssh_keys.each { |k| k.destroy if k.name == key_name }
    end
  end
end

task :upload_key do
  ChefDk::Helpers.upload_key_to_digitalocean!
end

task :delete_key do
  ChefDk::Helpers.delete_key_from_digitalocean!
end

Cane::RakeTask.new

RuboCop::RakeTask.new

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  Kernel.system 'countloc -r .'
end

desc 'Run knife cookbook syntax test'
task :cookbook_test do
  path = File.expand_path('../..', __FILE__)
  cb = File.basename(File.expand_path('..', __FILE__))
  Kernel.system "knife cookbook test -c test/knife.rb -o #{path} #{cb}"
  $CHILD_STATUS == 0 || fail('Cookbook syntax check failed!')
end

FoodCritic::Rake::LintTask.new do |f|
  f.options = { fail_tags: %w(any) }
end

RSpec::Core::RakeTask.new(:spec)

Kitchen::RakeTasks.new

task default: %w(cane rubocop loc cookbook_test foodcritic spec kitchen:all)
