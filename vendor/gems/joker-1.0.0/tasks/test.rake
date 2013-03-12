
desc('Test the ruby part of Joker')
task :test => 'build:native' do
    sh 'bacon -Ilib test/ruby/test_*.rb'
end

