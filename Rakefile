task :default => [:test]

desc 'Run the test suite'
task :test do
  ruby "-I .:lib:test test/tests.rb"
  `rm -rf .sass-cache`
end
