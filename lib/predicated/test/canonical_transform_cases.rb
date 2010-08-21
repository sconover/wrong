module CanonicalTransformCases
  
  module ClassMethods
    def create_canonical_tests(expectations, proper_typing=true)
      val = {
        :one => 1,
        :two => 2,
        :three => 3,
        :true_value => true,
        :false_value => false
      }
      
      val.each{|k,v|val[k]=v.to_s} unless proper_typing
      
      tests = {
        "simple operations" => {
          "eq" => Predicate{ Eq("a",val[:three]) },
          "gt" => Predicate{ Gt("a",val[:three]) },
          "lt" => Predicate{ Lt("a",val[:three]) },
          "gte" => Predicate{ Gte("a",val[:three]) },
          "lte" => Predicate{ Lte("a",val[:three]) }
        },
        "primitive types" => {
          "true" => Predicate{ Eq("a",val[:true_value]) },
          "false" => Predicate{ Eq("a",val[:false_value]) },
          "string" => Predicate{ Eq("a","yyy") },
        },
        "not" => {
          "simple" => Predicate{ Not(Eq("a",val[:true_value])) }
        },
        "simple and / or" => {
          "and" => Predicate{ And(Eq("a", val[:one]),Eq("b", val[:two])) },
          "or" => Predicate{ Or(Eq("a", val[:one]),Eq("b", val[:two])) }
        },
        "complex and / or" => {
          "or and" => Predicate{ Or(And(Eq("a", val[:one]),Eq("b", val[:two])), Eq("c",val[:three])) } 
        }
      }
  
      tests.each do |test_name, cases|
        test test_name do
          
          not_found = 
            cases.keys.sort.select do |case_name|
              expectations[test_name].nil? || 
              expectations[test_name][case_name].nil?
            end
          
          raise "no expectation defined for test: '#{test_name}'  cases: [#{not_found.join(", ")}]" unless not_found.empty?
          
          cases.each do |case_name, predicate|
            actual = block_given? ? yield(predicate) : predicate
            assert { actual == expectations[test_name][case_name] }
          end
        end
      end
    end
  end
  
  def self.included(other)
    other.extend(ClassMethods)
  end
end