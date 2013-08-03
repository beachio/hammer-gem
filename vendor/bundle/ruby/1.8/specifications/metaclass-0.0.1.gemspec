# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{metaclass}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Mead"]
  s.date = %q{2011-08-10}
  s.email = ["james@floehopper.org"]
  s.files = [".gitignore", "Gemfile", "README.md", "Rakefile", "lib/metaclass.rb", "lib/metaclass/object_methods.rb", "lib/metaclass/version.rb", "metaclass.gemspec", "test/object_methods_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/floehopper/metaclass}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{metaclass}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Adds a metaclass method to all Ruby objects}
  s.test_files = ["test/object_methods_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
