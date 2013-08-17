import 'lib/hammer/tasks/release.rake'

task :default => [:test]

desc 'Run the test suite'
task :test do
  ruby "-I test test/tests.rb"
  `rm -rf .sass-cache`
  Rake::Task['integration'].execute
  Rake::Task['functional'].execute
end

desc 'Run the integration tests'
task :integration do
  ruby "integration.rb"
end

desc 'Run the integration tests'
task :functional do
  ruby "functional.rb"
end