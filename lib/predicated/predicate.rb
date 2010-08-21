require "predicated/gem_check"
require "predicated/selectable"

module Predicated
  def Predicate(&block)
    result = nil
    Module.new do
      extend Predicate
      result = instance_eval(&block)
    end
    result
  end
  
  class Unary
    attr_accessor :inner
    
    def initialize(inner)
      @inner = inner
    end    
    
    module FlipThroughMe
      def each(ancestors=[], &block)
        yield([self, ancestors])
        ancestors_including_me = ancestors.dup + [self]
        inner.each(ancestors_including_me) { |item| block.call(item) } if inner.is_a?(Enumerable)
      end
    end
    include FlipThroughMe
    include Enumerable
    
    module ValueEquality
      def ==(other)
        self.class == other.class && 
        self.inner == other.inner
      end
    end
    include ValueEquality
  end
  
  class Binary
    attr_accessor :left, :right
    
    def initialize(left, right)
      @left = left
      @right = right
    end    
    
    module FlipThroughMe
      def each(ancestors=[], &block)
        yield([self, ancestors])
        ancestors_including_me = ancestors.dup + [self]
        enumerate_side(@left, ancestors_including_me, &block)
        enumerate_side(@right, ancestors_including_me, &block)
      end
      
      private 
      def enumerate_side(thing, ancestors)
        thing.each(ancestors) { |item| yield(item) } if thing.is_a?(Enumerable)
      end
    end
    include FlipThroughMe
    include Enumerable
    
    module ValueEquality
      def ==(other)
        self.class == other.class && 
        self.left == other.left && 
        self.right == other.right
      end
    end
    include ValueEquality
  end
  
  class Operation < Binary; end
  
  module Predicate
    extend Predicated::Selectable
    
    CLASS_INFO = [
      [:And, :And, Class.new(Binary)],
      [:Or, :Or, Class.new(Binary)],
      [:Not, :Not, Class.new(Unary)],
      [:Equal, :Eq, Class.new(Operation)],
      [:LessThan, :Lt, Class.new(Operation)],
      [:GreaterThan, :Gt, Class.new(Operation)],
      [:LessThanOrEqualTo, :Lte, Class.new(Operation)],
      [:GreaterThanOrEqualTo, :Gte, Class.new(Operation)]
    ]
    
    selectors =
      (CLASS_INFO.collect{|class_sym, sh, class_obj|class_obj} + [Unary, Binary, Operation]).
        inject({:all => proc{|predicate, enumerable|true}}) do |h, class_obj|
          h[class_obj] = proc{|predicate, enumerable|predicate.is_a?(class_obj)}
          h
        end

    CLASS_INFO.each do |operation_class_name, shorthand, class_object|
      Predicated.const_set(operation_class_name, class_object)
      class_object.instance_variable_set("@shorthand".to_sym, shorthand)
      class_object.class_eval do
        
        def self.shorthand
          @shorthand
        end
        
        include Selectable
        selector selectors
      end
      
      if class_object.ancestors.include?(Unary)
        module_eval(%{
          def #{shorthand}(inner)
            ::Predicated::#{operation_class_name}.new(inner)
          end
        })
      else
        module_eval(%{
          def #{shorthand}(left, right)
            ::Predicated::#{operation_class_name}.new(left, right)
          end
        })
      end
    end
  end
end

require "predicated/print"
