require "./test/test_helper_with_wrong"

require "predicated/from/json"
require "./test/canonical_transform_cases"
include Predicated

regarding "convert a json string to a predicate" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_json_str(%{["a","==",3]}),
      "gt" => Predicate.from_json_str(%{["a",">",3]}),
      "lt" => Predicate.from_json_str(%{["a","<",3]}),
      "gte" => Predicate.from_json_str(%{["a",">=",3]}),
      "lte" => Predicate.from_json_str(%{["a","<=",3]})
    },
    "primitive types" => {
      "false" => Predicate.from_json_str(%{["a","==",false]}),
      "true" => Predicate.from_json_str(%{["a","==",true]}),
      "string" => Predicate.from_json_str(%{["a","==","yyy"]})
    },
    "not" => {
      "simple" => Predicate.from_json_str(%{{"not":["a","==",true]}})
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_json_str(%{{"and":[["a","==",1],["b","==",2]]}}),
      "or" => Predicate.from_json_str(%{{"or":[["a","==",1],["b","==",2]]}})
    },
    "complex and / or" => {
      "or and" => Predicate.from_json_str(%{
        {
          "or":[
            {"and":[["a","==",1],["b","==",2]]},
            ["c","==",3]
          ]
        }
      })
    }
  }

  create_canonical_tests(@expectations)

end

regarding "convert a json structure to a predicate" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_json_struct(["a", "==", 3]),
      "gt" => Predicate.from_json_struct(["a", ">", 3]),
      "lt" => Predicate.from_json_struct(["a", "<", 3]),
      "gte" => Predicate.from_json_struct(["a", ">=", 3]),
      "lte" => Predicate.from_json_struct(["a", "<=", 3])
    },
    "primitive types" => {
      "false" => Predicate.from_json_struct(["a", "==", false]),
      "true" => Predicate.from_json_struct(["a", "==", true]),
      "string" => Predicate.from_json_struct(["a", "==", "yyy"])
    },
    "not" => {
      "simple" => Predicate.from_json_struct("not" => ["a", "==", true])
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_json_struct("and" => [["a", "==", 1],["b", "==", 2]]),
      "or" => Predicate.from_json_struct("or" => [["a", "==", 1],["b", "==", 2]])
    },
    "complex and / or" => {
      "or and" => Predicate.from_json_struct(
        "or" => [
          {"and" => [["a", "==", 1],["b", "==", 2]]}, 
          ["c", "==", 3]
        ]
      )
    }
  }

  create_canonical_tests(@expectations)

end