require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec
task :console do
  require 'irb'
  require 'irb/completion'
  require 'ruby-debug'
  $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
  require 'url_processor'
  ARGV.clear
  IRB.start
end
