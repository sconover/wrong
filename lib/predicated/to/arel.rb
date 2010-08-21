raise "this doesn't work in 1.8.6 because the arel gem is 1.8.7-only" if RUBY_VERSION=="1.8.6"

require "predicated/predicate"

module Predicated
  
  require_gem_version("arel", "0.4.0")
  
  class And
    def to_arel(arel_table)
      Arel::Predicates::And.new(left.to_arel(arel_table), right.to_arel(arel_table))
    end
  end
  
  class Or
    def to_arel(arel_table)
      Arel::Predicates::Or.new(left.to_arel(arel_table), right.to_arel(arel_table))
    end
  end
  
  class Not
    def to_arel(arel_table)
      Arel::Predicates::Not.new(inner.to_arel(arel_table))
    end
  end
  
  
  class Operation
    def to_arel(arel_table)
      arel_class.new(arel_table.attributes[left], right)
    end
  end
  
  class Equal; def arel_class; Arel::Predicates::Equality end end
  class LessThan; def arel_class; Arel::Predicates::LessThan end end
  class GreaterThan; def arel_class; Arel::Predicates::GreaterThan end end
  class LessThanOrEqualTo; def arel_class; Arel::Predicates::LessThanOrEqualTo end end
  class GreaterThanOrEqualTo; def arel_class; Arel::Predicates::GreaterThanOrEqualTo end end
  
  
end