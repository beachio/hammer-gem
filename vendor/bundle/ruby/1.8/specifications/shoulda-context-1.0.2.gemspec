# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shoulda-context}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["thoughtbot, inc.", "Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.date = %q{2012-12-18}
  s.default_executable = %q{convert_to_should_syntax}
  s.description = %q{Context framework extracted from Shoulda}
  s.email = %q{support@thoughtbot.com}
  s.executables = ["convert_to_should_syntax"]
  s.files = [".gitignore", "CONTRIBUTING.md", "Gemfile", "MIT-LICENSE", "README.md", "Rakefile", "bin/convert_to_should_syntax", "init.rb", "lib/shoulda-context.rb", "lib/shoulda/context.rb", "lib/shoulda/context/assertions.rb", "lib/shoulda/context/autoload_macros.rb", "lib/shoulda/context/context.rb", "lib/shoulda/context/proc_extensions.rb", "lib/shoulda/context/tasks.rb", "lib/shoulda/context/tasks/list_tests.rake", "lib/shoulda/context/tasks/yaml_to_shoulda.rake", "lib/shoulda/context/version.rb", "rails/init.rb", "shoulda-context.gemspec", "tasks/shoulda.rake", "test/fake_rails_root/test/shoulda_macros/custom_macro.rb", "test/fake_rails_root/vendor/gems/gem_with_macro-0.0.1/shoulda_macros/gem_macro.rb", "test/fake_rails_root/vendor/plugins/.keep", "test/fake_rails_root/vendor/plugins/plugin_with_macro/shoulda_macros/plugin_macro.rb", "test/shoulda/autoload_macro_test.rb", "test/shoulda/context_test.rb", "test/shoulda/convert_to_should_syntax_test.rb", "test/shoulda/helpers_test.rb", "test/shoulda/should_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://thoughtbot.com/community/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Context framework extracted from Shoulda}
  s.test_files = ["test/fake_rails_root/test/shoulda_macros/custom_macro.rb", "test/fake_rails_root/vendor/gems/gem_with_macro-0.0.1/shoulda_macros/gem_macro.rb", "test/fake_rails_root/vendor/plugins/.keep", "test/fake_rails_root/vendor/plugins/plugin_with_macro/shoulda_macros/plugin_macro.rb", "test/shoulda/autoload_macro_test.rb", "test/shoulda/context_test.rb", "test/shoulda/convert_to_should_syntax_test.rb", "test/shoulda/helpers_test.rb", "test/shoulda/should_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, ["~> 0.9.10"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, ["~> 2.1.0"])
    else
      s.add_dependency(%q<mocha>, ["~> 0.9.10"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<test-unit>, ["~> 2.1.0"])
    end
  else
    s.add_dependency(%q<mocha>, ["~> 0.9.10"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<test-unit>, ["~> 2.1.0"])
  end
end
