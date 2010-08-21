require "predicated/selectable"

module Predicated
  class Constraints
    def initialize
      @constraints = []
    end
    
    def add(constraint)
      @constraints << constraint
      self
    end
    
    def check(whole_predicate)
      result = ConstraintCheckResult.new
      
      @constraints.collect do |constraint|
        whole_predicate.select(*constraint.selectors).collect do |predicate, ancestors|
          if ! constraint.check(predicate, ancestors)
            result.violation(constraint, predicate)
          end
        end
      end
      
      result
    end
    
    def ==(other)
      @constraints == other.instance_variable_get("@constraints".to_sym)
    end
  end
  
  class Constraint
    attr_reader :name, :selectors
    def initialize(args)
      @name = args[:name]
      @selectors = args[:selectors] || [:all]
      @check_that = args[:check_that]
    end
    
    def check(predicate, ancestors)
      @check_that.call(predicate, ancestors)
    end
    
    def ==(other)
      @name == other.name && @selectors == other.selectors
    end
  end
  
  class ConstraintCheckResult
    attr_reader :violations
    def initialize
      @violations = {}
    end
    
    def pass?
      @violations.empty?
    end
    
    def violation(constraint, predicate)
      @violations[constraint] ||= []
      @violations[constraint] << predicate
      self
    end
  end
end