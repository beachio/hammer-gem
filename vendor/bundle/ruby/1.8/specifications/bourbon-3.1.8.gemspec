# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bourbon}
  s.version = "3.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phil LaPier", "Chad Mazzola", "Matt Jankowski", "Nick Quaranto", "Jeremy Raines", "Mike Burns", "Andres Mejia", "Travis Haynes", "Chris Lloyd", "Gabe Berke-Williams", "J. Edward Dewyea", "Reda Lemeden"]
  s.date = %q{2013-06-11}
  s.default_executable = %q{bourbon}
  s.description = %q{The purpose of Bourbon Vanilla Sass Mixins is to provide a comprehensive framework of
sass mixins that are designed to be as vanilla as possible. Meaning they
should not deter from the original CSS syntax. The mixins contain vendor
specific prefixes for all CSS3 properties for support amongst modern
browsers. The prefixes also ensure graceful degradation for older browsers
that support only CSS3 prefixed properties.
}
  s.email = ["support@thoughtbot.com"]
  s.executables = ["bourbon"]
  s.files = [".gitignore", "Gemfile", "Gemfile.lock", "LICENSE", "Rakefile", "app/assets/stylesheets/_bourbon-deprecated-upcoming.scss", "app/assets/stylesheets/_bourbon.scss", "app/assets/stylesheets/addons/_button.scss", "app/assets/stylesheets/addons/_clearfix.scss", "app/assets/stylesheets/addons/_font-family.scss", "app/assets/stylesheets/addons/_hide-text.scss", "app/assets/stylesheets/addons/_html5-input-types.scss", "app/assets/stylesheets/addons/_position.scss", "app/assets/stylesheets/addons/_prefixer.scss", "app/assets/stylesheets/addons/_retina-image.scss", "app/assets/stylesheets/addons/_size.scss", "app/assets/stylesheets/addons/_timing-functions.scss", "app/assets/stylesheets/addons/_triangle.scss", "app/assets/stylesheets/css3/_animation.scss", "app/assets/stylesheets/css3/_appearance.scss", "app/assets/stylesheets/css3/_backface-visibility.scss", "app/assets/stylesheets/css3/_background-image.scss", "app/assets/stylesheets/css3/_background.scss", "app/assets/stylesheets/css3/_border-image.scss", "app/assets/stylesheets/css3/_border-radius.scss", "app/assets/stylesheets/css3/_box-sizing.scss", "app/assets/stylesheets/css3/_columns.scss", "app/assets/stylesheets/css3/_flex-box.scss", "app/assets/stylesheets/css3/_font-face.scss", "app/assets/stylesheets/css3/_hidpi-media-query.scss", "app/assets/stylesheets/css3/_image-rendering.scss", "app/assets/stylesheets/css3/_inline-block.scss", "app/assets/stylesheets/css3/_keyframes.scss", "app/assets/stylesheets/css3/_linear-gradient.scss", "app/assets/stylesheets/css3/_perspective.scss", "app/assets/stylesheets/css3/_placeholder.scss", "app/assets/stylesheets/css3/_radial-gradient.scss", "app/assets/stylesheets/css3/_transform.scss", "app/assets/stylesheets/css3/_transition.scss", "app/assets/stylesheets/css3/_user-select.scss", "app/assets/stylesheets/functions/_compact.scss", "app/assets/stylesheets/functions/_flex-grid.scss", "app/assets/stylesheets/functions/_grid-width.scss", "app/assets/stylesheets/functions/_linear-gradient.scss", "app/assets/stylesheets/functions/_modular-scale.scss", "app/assets/stylesheets/functions/_px-to-em.scss", "app/assets/stylesheets/functions/_radial-gradient.scss", "app/assets/stylesheets/functions/_tint-shade.scss", "app/assets/stylesheets/functions/_transition-property-name.scss", "app/assets/stylesheets/helpers/_deprecated-webkit-gradient.scss", "app/assets/stylesheets/helpers/_gradient-positions-parser.scss", "app/assets/stylesheets/helpers/_linear-positions-parser.scss", "app/assets/stylesheets/helpers/_radial-arg-parser.scss", "app/assets/stylesheets/helpers/_radial-positions-parser.scss", "app/assets/stylesheets/helpers/_render-gradients.scss", "app/assets/stylesheets/helpers/_shape-size-stripper.scss", "bin/bourbon", "bourbon.gemspec", "features/install.feature", "features/step_definitions/bourbon_steps.rb", "features/support/bourbon_support.rb", "features/support/env.rb", "features/update.feature", "features/version.feature", "lib/bourbon.rb", "lib/bourbon/engine.rb", "lib/bourbon/generator.rb", "lib/bourbon/version.rb", "lib/tasks/install.rake", "readme.md"]
  s.homepage = %q{https://github.com/thoughtbot/bourbon}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{bourbon}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Bourbon Sass Mixins using SCSS syntax.}
  s.test_files = ["features/install.feature", "features/step_definitions/bourbon_steps.rb", "features/support/bourbon_support.rb", "features/support/env.rb", "features/update.feature", "features/version.feature"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sass>, [">= 3.2.0"])
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<sass>, [">= 3.2.0"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<aruba>, ["~> 0.4"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<sass>, [">= 3.2.0"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<aruba>, ["~> 0.4"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
