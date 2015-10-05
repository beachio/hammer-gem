Gem::Specification.new do |gem|
  gem.name          = "hammer"
  gem.version       = '5.3.0'
  gem.authors       = ["Elliott Kember", "Alexander Dikhtiarenko"]
  gem.email         = ["aleks.ewq@gmail.com"]
  gem.description   = "Hammer compilation gem"
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'amp', '>=0.11'
  gem.add_dependency 'bourbon'
  gem.add_dependency 'neat', '1.7.0'
  gem.add_dependency 'coffee-script', '~> 2.2.0'
  gem.add_dependency 'eco'
  gem.add_dependency 'ejs'
  gem.add_dependency 'haml'
  gem.add_dependency 'json_pure', '~> 1.8.0'
  gem.add_dependency 'kramdown', '1.3.1'
  gem.add_dependency 'mocha', '0.14.0'
  gem.add_dependency 'slim'
  gem.add_dependency 'plist'
  gem.add_dependency 'sass'
  gem.add_dependency 'shoulda'
  gem.add_dependency 'uglifier', '2.1.2'
  gem.add_dependency 'execjs', '2.0.2'
  gem.add_dependency 'test-unit'
  gem.add_dependency 'parallel'
  gem.add_dependency 'autoprefixer-rails'
end