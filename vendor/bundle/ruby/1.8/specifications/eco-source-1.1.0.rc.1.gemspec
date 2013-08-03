# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{eco-source}
  s.version = "1.1.0.rc.1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Stephenson"]
  s.date = %q{2011-06-04}
  s.description = %q{JavaScript source code for the Eco (Embedded CoffeeScript template language) compiler}
  s.email = %q{sstephenson@gmail.com}
  s.files = ["lib/eco/eco.js", "lib/eco/source.rb"]
  s.homepage = %q{https://github.com/sstephenson/eco/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Eco compiler source}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
