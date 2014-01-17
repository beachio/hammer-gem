require 'hammer/templates/base'

# We're going to need the class for each line. It's in the "application" folder in templates.
require File.join(File.dirname(__FILE__), 'application', 'application_template_line_template')

module Hammer
  class ApplicationTemplate < BaseTemplate

    def initialize(options)
      @project = options[:project]
    end

    def to_s
      return @text if @text
      application_template_path = File.join(File.dirname(__FILE__), "application", "application.html.erb")
      template_contents = File.new(application_template_path).read
      template = ERB.new(template_contents, nil, "%")
      @text = template.result(binding)
    end

  private

    # Used in an #each for the list of files in the output.
    def line_for(file)
      Hammer::ApplicationTemplateLineTemplate.new(:hammer_file => file)
    end
  end
end