require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

require "predicated/from/ruby_code_string"
include Predicated

regarding "ruby code string - canoical transform cases" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_ruby_code_string("'a'==3"),
      "gt" => Predicate.from_ruby_code_string("'a'>3"),
      "lt" => Predicate.from_ruby_code_string("'a'<3"),
      "gte" => Predicate.from_ruby_code_string("'a'>=3"),
      "lte" => Predicate.from_ruby_code_string("'a'<=3")
    },
    "primitive types" => {
      "false" => Predicate.from_ruby_code_string("'a'==false"),
      "true" => Predicate.from_ruby_code_string("'a'==true"),
      "string" => Predicate.from_ruby_code_string("'a'=='yyy'"),
    },
    "not" => {
      "simple" => Predicate.from_ruby_code_string("!('a'==true)")
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_ruby_code_string("'a'==1 && 'b'==2"),
      "or" => Predicate.from_ruby_code_string("'a'==1 || 'b'==2")
    },
    "complex and / or" => {
      "or and" => Predicate.from_ruby_code_string("'a'==1 && 'b'==2 || 'c'==3")
    }
  }

  create_canonical_tests(@expectations)
end
