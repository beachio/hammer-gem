module NotArray
  def self.included(base)
    base.class_eval do
      def each(&block)
        raise "You tried iterate over not array!"
      end
    
      def [](key)
        raise "It isn't array !"
      end
    
      def first
        raise "It isn't array !"
      end

      alias_method :last, :first
      alias_method :take, :first
      alias_method :count, :first
    end
  end
end