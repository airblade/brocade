require 'bundler/gem_tasks'

require 'rake/testtask'

desc 'Test the brocade plugin.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Default: run unit tests.'
task :default => :test
