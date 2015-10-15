# require content modules
if $root_dir
  modules_path = File.join($root_dir, 'lib', 'hammer', 'content', '**/*.rb')
else
  modules_path = File.join(File.dirname(__FILE__), '..', 'content', '**/*.rb')
end
Dir[modules_path].each {|file| require file; }