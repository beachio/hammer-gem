require 'rake/testtask'
import 'lib/hammer/tasks/coverage.rake'
import 'lib/hammer/tasks/release.rake'

task :default => :test

def scope(path)
  File.join(File.dirname(__FILE__), path)
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  test_files = FileList[scope('test/**/*_test.rb')]
  t.test_files = test_files
  t.verbose = true
end