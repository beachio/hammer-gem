task :default => [:test]


task :test do
  ruby "-I .:lib:test test/tests.rb"
  `rm -rf .sass-cache`
end
