module Hammer
  class JSONTemplate < Template
    def to_s
      @files.to_json
    end
  end
end