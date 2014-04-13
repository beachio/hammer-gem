# -*- encoding: utf-8 -*-
# stub: test-unit 2.5.5 ruby lib

Gem::Specification.new do |s|
  s.name = "test-unit"
  s.version = "2.5.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kouhei Sutou", "Haruka Yoshihara"]
  s.date = "2013-05-18"
  s.description = "Ruby 1.9.x bundles minitest not Test::Unit. Test::Unit\nbundled in Ruby 1.8.x had not been improved but unbundled\nTest::Unit (test-unit) is improved actively.\n"
  s.email = ["kou@cozmixng.org", "yoshihara@clear-code.com"]
  s.homepage = "http://test-unit.rubyforge.org/"
  s.licenses = ["Ruby's and PSFL (lib/test/unit/diff.rb)"]
  s.rubyforge_project = "test-unit"
  s.rubygems_version = "2.2.1"
  s.summary = "test-unit - Improved version of Test::Unit bundled in Ruby 1.8.x."

  s.installed_by_version = "2.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<RedCloth>, [">= 0"])
      s.add_development_dependency(%q<packnga>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<RedCloth>, [">= 0"])
      s.add_dependency(%q<packnga>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<RedCloth>, [">= 0"])
    s.add_dependency(%q<packnga>, [">= 0"])
  end
end
