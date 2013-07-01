require "bundler/gem_tasks"
require "rspec/core/rake_task"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

load "lib/rqd2/tasks/rqd2.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec