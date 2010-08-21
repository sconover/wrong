require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

require "predicated/to/json"
include Predicated

regarding "convert a predicate to a json structure" do
  include CanonicalTransformCases
  
  @to_expectations = {
    "simple operations" => {
      "eq" => ["a", "==", 3],
      "gt" => ["a", ">", 3],
      "lt" => ["a", "<", 3],
      "gte" => ["a", ">=", 3],
      "lte" => ["a", "<=", 3]
    },
    "primitive types" => {
      "false" => ["a", "==", false],
      "true" => ["a", "==", true],
      "string" => ["a", "==", "yyy"]
    },
    "not" => {
      "simple" => {"not" => ["a", "==", true]}
    },
    "simple and / or" => {
      "and" => {"and" => [["a", "==", 1], ["b", "==", 2]] },
      "or" =>  {"or" =>  [["a", "==", 1], ["b", "==", 2]] }
    },
    "complex and / or" => {
      "or and" => {"or" =>  [
                    {"and" => [["a", "==", 1], ["b", "==", 2]]},
                    ["c", "==", 3]
                   ]}
    }
  }
  
  create_canonical_tests(@to_expectations) do |predicate|
    predicate.to_json_struct
  end
end

regarding "convert a predicate to a json string" do
  include CanonicalTransformCases
  
  @to_expectations = {
    "simple operations" => {
      "eq" => %{["a","==",3]},
      "gt" => %{["a",">",3]},
      "lt" => %{["a","<",3]},
      "gte" => %{["a",">=",3]},
      "lte" => %{["a","<=",3]}
    },
    "primitive types" => {
      "false" => %{["a","==",false]},
      "true" =>  %{["a","==",true]},
      "string" => %{["a","==","yyy"]}
    },
    "not" => {
      "simple" => %{{"not":["a","==",true]}}
    },
    "simple and / or" => {
      "and" => %{{"and":[["a","==",1],["b","==",2]]}},
      "or" =>  %{{"or":[["a","==",1],["b","==",2]]}}
    },
    "complex and / or" => {
      "or and" => %{{"or":[{"and":[["a","==",1],["b","==",2]]},["c","==",3]]}}
    }
  }
  
  create_canonical_tests(@to_expectations) do |predicate|
    predicate.to_json_str.gsub("\n", "").gsub(" ", "")
  end
end