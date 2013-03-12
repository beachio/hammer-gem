require 'rake/extensiontask'
require 'rake/extensiontesttask'

extension_task =
Rake::ExtensionTask.new('joker_native', $gemspec) do |ext|
    ext.cross_compile   = true
    ext.cross_platform  = 'x86-mswin32'
    ext.test_files      = FileList['test/c/*']
end

CLEAN.include 'lib/**/*.so'


# workaround for rake-compiler which needs the gemspec to have a
# version and yaml-dump-loads the
# gemspec which leads to errors since procs can't be loaded
Rake::Task.tasks.each do |task_name|
    case task_name.to_s
    when /^native/
        task_name.prerequisites.unshift("gemspec", "fix_rake_compiler_gemspec_dump")
    end
end

task :fix_rake_compiler_gemspec_dump do
    %w{files extra_rdoc_files test_files}.each do |accessor|
        $gemspec.send(accessor).instance_eval { @exclude_procs = Array.new }
    end
end

