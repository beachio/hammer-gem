# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shoulda}
  s.version = "3.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.date = %q{2012-10-19}
  s.description = %q{Making tests easy on the fingers and eyes}
  s.email = %q{support@thoughtbot.com}
  s.files = [".autotest", ".gitignore", ".travis.yml", "Appraisals", "CONTRIBUTING.md", "Gemfile", "MIT-LICENSE", "README.md", "Rakefile", "features/rails_integration.feature", "features/step_definitions/rails_steps.rb", "features/support/env.rb", "gemfiles/3.0.gemfile", "gemfiles/3.0.gemfile.lock", "gemfiles/3.1.gemfile", "gemfiles/3.1.gemfile.lock", "gemfiles/3.2.gemfile", "gemfiles/3.2.gemfile.lock", "lib/shoulda.rb", "lib/shoulda/version.rb", "shoulda.gemspec"]
  s.homepage = %q{https://github.com/thoughtbot/shoulda}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Making tests easy on the fingers and eyes}
  s.test_files = ["features/rails_integration.feature", "features/step_definitions/rails_steps.rb", "features/support/env.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<shoulda-context>, ["~> 1.0.1"])
      s.add_runtime_dependency(%q<shoulda-matchers>, ["~> 1.4.1"])
      s.add_development_dependency(%q<appraisal>, ["~> 0.4.0"])
      s.add_development_dependency(%q<rails>, ["= 3.0.12"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.7.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.1.0"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4.11"])
    else
      s.add_dependency(%q<shoulda-context>, ["~> 1.0.1"])
      s.add_dependency(%q<shoulda-matchers>, ["~> 1.4.1"])
      s.add_dependency(%q<appraisal>, ["~> 0.4.0"])
      s.add_dependency(%q<rails>, ["= 3.0.12"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.7.0"])
      s.add_dependency(%q<cucumber>, ["~> 1.1.0"])
      s.add_dependency(%q<aruba>, ["~> 0.4.11"])
    end
  else
    s.add_dependency(%q<shoulda-context>, ["~> 1.0.1"])
    s.add_dependency(%q<shoulda-matchers>, ["~> 1.4.1"])
    s.add_dependency(%q<appraisal>, ["~> 0.4.0"])
    s.add_dependency(%q<rails>, ["= 3.0.12"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.7.0"])
    s.add_dependency(%q<cucumber>, ["~> 1.1.0"])
    s.add_dependency(%q<aruba>, ["~> 0.4.11"])
  end
end
