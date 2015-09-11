# A legacy file for Hammer Mac App compatibility.

ruby_version = RUBY_VERSION.to_f >= 2.0 ? '2.0.0' : '1.8'
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/vendor/*/bundle/ruby/#{ruby_version}/gems/*/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/vendor/*/bundle/ruby/#{ruby_version}/bundler/gems/*/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/lib")
$LOAD_PATH.concat Dir.glob("#{Dir.pwd}/bin")

load File.join(File.dirname(__FILE__), "bin", "compile_preload")