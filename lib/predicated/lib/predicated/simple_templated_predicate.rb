require "predicated/predicate"
require "predicated/evaluate"

module Predicated
  def SimpleTemplatedPredicate(&block)
    result = nil
    Module.new do
      extend SimpleTemplatedShorthand
      result = instance_eval(&block)
    end
    result
  end
  
  class And
    def fill_in(placeholder_replacement)
      And.new(left.fill_in(placeholder_replacement), right.fill_in(placeholder_replacement))
    end
  end
  
  class Or
    def fill_in(placeholder_replacement)
      Or.new(left.fill_in(placeholder_replacement), right.fill_in(placeholder_replacement))
    end
  end
  
  class Not
    def fill_in(placeholder_replacement)
      Not.new(inner.fill_in(placeholder_replacement))
    end
  end
  
  class Operation
    def fill_in(placeholder_replacement)
      self.class.new(placeholder_replacement, right)
    end
  end
  
  class Call
    def fill_in(placeholder_replacement)
      self.class.new(placeholder_replacement, method_sym, right)
    end
  end
  
  class Placeholder; end
  
  module SimpleTemplatedShorthand
    include Shorthand
    
    def Eq(right) ::Predicated::Equal.new(Placeholder, right) end
    def Lt(right) ::Predicated::LessThan.new(Placeholder, right) end
    def Gt(right) ::Predicated::GreaterThan.new(Placeholder, right) end
    def Lte(right) ::Predicated::LessThanOrEqualTo.new(Placeholder, right) end
    def Gte(right) ::Predicated::GreaterThanOrEqualTo.new(Placeholder, right) end    

    def Call(method_sym, right=[]) ::Predicated::Call.new(Placeholder, method_sym, right) end    
  end
  
  class Operation < Binary
    def to_s
      if left == Placeholder
        "#{self.class.shorthand}(#{part_to_s(right)})"
      else
        super
      end
    end
  end

  class Call < Operation
    def to_s
      if left == Placeholder
        "Call(#{method_sym.to_s}(#{part_to_s(right)}))"
      else
        super
      end
    end
  end
  
  
end