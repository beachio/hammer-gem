# require content modules
if $root_dir
  modules_path = File.join($root_dir, 'lib', 'hammer', 'content', '*.rb')
  submodules_path = File.join($root_dir, 'lib', 'hammer', 'content', '**/*.rb')
else
  modules_path = File.join(File.dirname(__FILE__), '..', 'content', '*.rb')
  submodules_path = File.join(File.dirname(__FILE__), '..', 'content', '**/*.rb')
end

modules_paths = Dir[modules_path]
modules_paths = modules_paths.concat(Dir[submodules_path] - Dir[modules_path])

modules_paths.each do |file|
 require file
end
