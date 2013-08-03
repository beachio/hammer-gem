task :default => [:test]

desc 'Run the test suite'
task :test do
  ruby "-I .:lib:test test/tests.rb"
  `rm -rf .sass-cache`
  Rake::Task['integration'].execute
end

desc 'Run the integration tests'
task :integration do
  ruby "integration.rb"
end
