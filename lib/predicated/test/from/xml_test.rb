require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

require "predicated/from/xml"
include Predicated

regarding "convert an xml string to a predicate" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_xml("<equal><left>a</left><right>3</right></equal>"),
      "gt" => Predicate.from_xml("<greaterThan><left>a</left><right>3</right></greaterThan>"),
      "lt" => Predicate.from_xml("<lessThan><left>a</left><right>3</right></lessThan>"),
      "gte" => 
        Predicate.from_xml("<greaterThanOrEqualTo><left>a</left><right>3</right></greaterThanOrEqualTo>"),
      "lte" => 
        Predicate.from_xml("<lessThanOrEqualTo><left>a</left><right>3</right></lessThanOrEqualTo>")
    },
    "primitive types" => {
      "false" => Predicate.from_xml("<equal><left>a</left><right>false</right></equal>"),
      "true" => Predicate.from_xml("<equal><left>a</left><right>true</right></equal>"),
      "string" => Predicate.from_xml("<equal><left>a</left><right>yyy</right></equal>"),
    },
    "not" => {
      "simple" => Predicate.from_xml("<not><equal><left>a</left><right>true</right></equal></not>")
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_xml(%{
        <and>
          <equal><left>a</left><right>1</right></equal>
          <equal><left>b</left><right>2</right></equal>
        </and>
      }),
      "or" => Predicate.from_xml(%{
        <or>
          <equal><left>a</left><right>1</right></equal>
          <equal><left>b</left><right>2</right></equal>
        </or>
      })
    },
    "complex and / or" => {
      "or and" => Predicate.from_xml(%{
        <or>
          <and>
            <equal><left>a</left><right>1</right></equal>
            <equal><left>b</left><right>2</right></equal>
          </and>
          <equal><left>c</left><right>3</right></equal>
        </or>
      })
    }
  }

  create_canonical_tests(@expectations, proper_typing=false)
end
