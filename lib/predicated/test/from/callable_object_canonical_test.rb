require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

if RUBY_VERSION =~/^1.9/
  puts "skipping callable object-related tests in 1.9"
else
  
require "predicated/from/callable_object"
include Predicated

regarding "callable object - canoical transform cases" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_callable_object{"a"==3},
      "gt" => Predicate.from_callable_object{"a">3},
      "lt" => Predicate.from_callable_object{"a"<3},
      "gte" => Predicate.from_callable_object{"a">=3},
      "lte" => Predicate.from_callable_object{"a"<=3}
    },
    "primitive types" => {
      "false" => Predicate.from_callable_object{"a"==false},
      "true" => Predicate.from_callable_object{"a"==true},
      "string" => Predicate.from_callable_object{"a"=="yyy"}
    },
    "not" => {
      "simple" => Predicate.from_callable_object{!("a"==true)}
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_callable_object{"a"==1 && "b"==2},
      "or" => Predicate.from_callable_object{"a"==1 || "b"==2}
    },
    "complex and / or" => {
      "or and" => Predicate.from_callable_object{"a"==1 && "b"==2 || "c"==3}
    }
  }

  create_canonical_tests(@expectations)
end

end