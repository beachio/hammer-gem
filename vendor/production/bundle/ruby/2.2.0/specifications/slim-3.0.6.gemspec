# -*- encoding: utf-8 -*-
# stub: slim 3.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "slim"
  s.version = "3.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Daniel Mendler", "Andrew Stone", "Fred Wu"]
  s.date = "2015-06-05"
  s.description = "Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic."
  s.email = ["mail@daniel-mendler.de", "andy@stonean.com", "ifredwu@gmail.com"]
  s.executables = ["slimrb"]
  s.files = ["bin/slimrb"]
  s.homepage = "http://slim-lang.com/"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.4.8"
  s.summary = "Slim is a template language."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<temple>, ["~> 0.7.3"])
      s.add_runtime_dependency(%q<tilt>, ["< 2.1", ">= 1.3.3"])
    else
      s.add_dependency(%q<temple>, ["~> 0.7.3"])
      s.add_dependency(%q<tilt>, ["< 2.1", ">= 1.3.3"])
    end
  else
    s.add_dependency(%q<temple>, ["~> 0.7.3"])
    s.add_dependency(%q<tilt>, ["< 2.1", ">= 1.3.3"])
  end
end
