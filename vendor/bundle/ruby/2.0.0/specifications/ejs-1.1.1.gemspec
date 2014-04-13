# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ejs"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Stephenson"]
  s.date = "2012-06-07"
  s.description = "Compile and evaluate EJS (Embedded JavaScript) templates from Ruby."
  s.email = ["sstephenson@gmail.com"]
  s.homepage = "https://github.com/sstephenson/ruby-ejs/"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "EJS (Embedded JavaScript) template compiler"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<execjs>, ["~> 0.4"])
    else
      s.add_dependency(%q<execjs>, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<execjs>, ["~> 0.4"])
  end
end
