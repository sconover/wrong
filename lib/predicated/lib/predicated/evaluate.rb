require "predicated/predicate"

module Predicated
  
  
  class Operation < Binary
    attr_reader :method_sym
    
    def initialize(left, method_sym, right)
      super(left, right)
      @method_sym = method_sym
    end    

    def evaluate
      right_values = right.nil? ? [nil] : right #1.9 problem where nils and varargs don't play nicely
      left.send(@method_sym, *right_values)
    end
    
    def ==(other)
      super && method_sym==other.method_sym
    end
  end
  

  class Equal < Operation; def initialize(left, right); super(left, :==, right); end end
  class LessThan < Operation; def initialize(left, right); super(left, :<, right); end end
  class GreaterThan < Operation; def initialize(left, right); super(left, :>, right); end end
  class LessThanOrEqualTo < Operation; def initialize(left, right); super(left, :<=, right); end end
  class GreaterThanOrEqualTo < Operation; def initialize(left, right); super(left, :>=, right); end end

  class Call < Operation
    def self.shorthand
      :Call
    end

    def initialize(left, method_sym, right=[])
      super
    end    
    
    def to_s
      "Call(#{left_to_s}.#{method_sym.to_s}#{right_to_s})"
    end
    
    private 
    def left_to_s
      part_to_s(left)
    end

    def right_to_s
      values = right.is_a?(::Enumerable) ? right : [right]
      values.empty? ? "" :
        "(" + values.collect{|arg|part_to_s(arg)}.join(",") + ")"
    end
  end
  Shorthand.module_eval(%{
    def Call(left_object, method_sym, right_args=[])
      ::Predicated::Call.new(left_object, method_sym, right_args)
    end
  })
  
  module Container
    private 
    def boolean_or_evaluate(thing)
      if thing.is_a?(FalseClass)
        false
      elsif thing.is_a?(TrueClass)
        true
      else
        thing.evaluate
      end
    end
  end

  class And
    include Container
    def evaluate
      boolean_or_evaluate(left) && boolean_or_evaluate(right)
    end 
  end

  class Or
    include Container
    def evaluate
      boolean_or_evaluate(left) || boolean_or_evaluate(right)
    end 
  end

  class Not
    include Container
    def evaluate
      ! boolean_or_evaluate(inner)
    end 
  end
end
