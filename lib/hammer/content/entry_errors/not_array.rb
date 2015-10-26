module NotArray
  def self.included(base)
    base.class_eval do
      def each(&block)
        not_array_error "You tried to iterate over '#{@field_name}' but this \
        variable is not array."
      end
    
      def [](key)
        not_array_error
      end

      def not_array_error(message = nil)
        message ||= "You tried to access '#{@field_name}' but this variable is \
        not array."
        raise Hammer::SmartException.new(message, text: 'Variable is not array.')
      end

      alias_method :first, :not_array_error
      alias_method :last, :not_array_error
      alias_method :take, :not_array_error
      alias_method :count, :not_array_error
    end
  end
end