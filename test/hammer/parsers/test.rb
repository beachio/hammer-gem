# #!/usr/bin/ruby

# module TheModule
#   def self.included(base)
#     base.send :alias_method, :parse_without_optimization, :parse

#     puts "Overriding #parse in #{base}..."

#     base.send :define_method, :parse , Proc.new { |text| 
#       puts "Module!"
#       parse_without_optimization(text)
#       return text
#     }
#   end
# end

# class TheClass

#   def parse(text)
#     puts "Class!"
#   end

#   include TheModule
# end

# TheClass.new().parse('hi')