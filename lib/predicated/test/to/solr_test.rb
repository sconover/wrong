require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

require "predicated/to/solr"
include Predicated

regarding "convert a predicate to a solr query" do
  include CanonicalTransformCases
  
  @to_expectations = {
    "simple operations" => {
      "eq" => "a:3",
      "gt" => "a:[4 TO *]",
      "lt" => "a:[* TO 2]",
      "gte" => "a:[3 TO *]",
      "lte" => "a:[* TO 3]"
    },
    "primitive types" => {
      "false" => "a:false",
      "true" => "a:true",
      "string" => "a:yyy"
    },
    "not" => {
      "simple" => "NOT(a:true)"
    },
    "simple and / or" => {
      "and" => "(a:1 AND b:2)", #parens are necessary around AND's in solr in order to force precedence
      "or" => "(a:1 OR b:2)",
    },
    "complex and / or" => {
      "or and" => "((a:1 AND b:2) OR c:3)"
    }
  }
  
  create_canonical_tests(@to_expectations) do |predicate|
    predicate.to_solr
  end

end