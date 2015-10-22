module Hammer
  class ExceptionTemplate < Template

    def to_s
      return @text if @text
      application_template_path = File.join(
        File.dirname(__FILE__),
        'application',
        'exception.html.erb'
      )
      template_contents = File.new(application_template_path).read
      template = ERB.new(template_contents, nil, '%')
      @text = template.result(binding)
    end
    
  end
end