# -*- encoding: utf-8 -*-
# stub: mocha 0.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mocha"
  s.version = "0.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["James Mead"]
  s.date = "2013-05-14"
  s.description = "Mocking and stubbing library with JMock/SchMock syntax, which allows mocking and stubbing of methods on real (non-mock) classes."
  s.email = "mocha-developer@googlegroups.com"
  s.homepage = "http://gofreerange.com/mocha/docs"
  s.rubyforge_project = "mocha"
  s.rubygems_version = "2.2.1"
  s.summary = "Mocking and stubbing library"

  s.installed_by_version = "2.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<metaclass>, ["~> 0.0.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<introspection>, ["~> 0.0.1"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<redcarpet>, ["~> 1"])
    else
      s.add_dependency(%q<metaclass>, ["~> 0.0.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<introspection>, ["~> 0.0.1"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<redcarpet>, ["~> 1"])
    end
  else
    s.add_dependency(%q<metaclass>, ["~> 0.0.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<introspection>, ["~> 0.0.1"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<redcarpet>, ["~> 1"])
  end
end
