# Encoding: UTF-8

require 'rubygems'
require 'English'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'kitchen/rake_tasks'

Cane::RakeTask.new

Rubocop::RakeTask.new do |task|
  task.patterns = %w(**/*.rb)
end

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

desc 'Run all tests that do not require a converge'
task everything_but_the_kitchen: [
  :cane, :rubocop, :loc, :cookbook_test, :foodcritic, :spec
]

task default: [
  :everything_but_the_kitchen # , 'kitchen:all'
]
