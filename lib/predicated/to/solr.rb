require "predicated/predicate"

module Predicated
  
  class And; def to_solr; "(#{left.to_solr} AND #{right.to_solr})" end end
  class Or;  def to_solr; "(#{left.to_solr} OR #{right.to_solr})" end end
  class Not; def to_solr; "NOT(#{inner.to_solr})" end end
  
  class Equal;                def to_solr; "#{left}:#{right}" end end
  class GreaterThan;          def to_solr; "#{left}:[#{(right+1)} TO *]" end end
  class LessThan;             def to_solr; "#{left}:[* TO #{(right-1)}]" end end  
  class GreaterThanOrEqualTo; def to_solr; "#{left}:[#{right} TO *]" end end
  class LessThanOrEqualTo;    def to_solr; "#{left}:[* TO #{right}]" end end
  
end