# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{eco}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Stephenson"]
  s.date = %q{2011-06-04}
  s.description = %q{    Ruby Eco is a bridge to the official JavaScript Eco compiler.
}
  s.email = %q{sstephenson@gmail.com}
  s.files = ["lib/eco.rb", "LICENSE", "README.md"]
  s.homepage = %q{https://github.com/sstephenson/ruby-eco}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby Eco Compiler (Embedded CoffeeScript templates)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coffee-script>, [">= 0"])
      s.add_runtime_dependency(%q<eco-source>, [">= 0"])
      s.add_runtime_dependency(%q<execjs>, [">= 0"])
    else
      s.add_dependency(%q<coffee-script>, [">= 0"])
      s.add_dependency(%q<eco-source>, [">= 0"])
      s.add_dependency(%q<execjs>, [">= 0"])
    end
  else
    s.add_dependency(%q<coffee-script>, [">= 0"])
    s.add_dependency(%q<eco-source>, [">= 0"])
    s.add_dependency(%q<execjs>, [">= 0"])
  end
end
