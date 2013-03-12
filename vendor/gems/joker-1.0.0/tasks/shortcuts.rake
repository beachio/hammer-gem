
desc("Build linux and windows specific gems")
task :gems do
    sh "rake clean build:native"
    sh "rake clean build:cross"
    sh "rake clean build"
end

task "build:native" => [:no_extconf, :native, :build] do
    file = "pkg/joker-#{`cat VERSION`.chomp}.gem"
    mv file, "#{file.ext}-i686-linux.gem"
end

task "build:cross" => [:no_extconf, :cross, :native, :build] do
    file = "pkg/joker-#{`cat VERSION`.chomp}.gem"
    mv file, "#{file.ext}-x86-mingw32.gem"
end

task :no_extconf do
    $gemspec.extensions = []
end

