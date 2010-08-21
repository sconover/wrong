require "./test/test_helper_with_wrong"

require "predicated/from/url_part"
require "./test/canonical_transform_cases"
include Predicated

regarding "parse url parts and convert them into predicates" do
  include CanonicalTransformCases

  @expectations = {
    "simple operations" => {
      "eq" => Predicate.from_url_part("a=3"),
      "gt" => Predicate.from_url_part("a>3"),
      "lt" => Predicate.from_url_part("a<3"),
      "gte" => Predicate.from_url_part("a>=3"),
      "lte" => Predicate.from_url_part("a<=3")
    },
    "primitive types" => {
      "false" => Predicate.from_url_part("a=false"),
      "true" => Predicate.from_url_part("a=true"),
      "string" => Predicate.from_url_part("a=yyy"),
    },
    "not" => {
      "simple" => Predicate.from_url_part("!(a=true)")
    },
    "simple and / or" => {
      #parens are necessary around AND's in solr in order to force precedence
      "and" => Predicate.from_url_part("a=1&b=2"),
      "or" => Predicate.from_url_part("a=1|b=2")
    },
    "complex and / or" => {
      "or and" => Predicate.from_url_part("a=1&b=2|c=3")
    }
  }

  create_canonical_tests(@expectations, proper_typing=false)


  
  test "parens change precedence" do
    assert { Predicate.from_url_part("a=1|b=2&c=3") == 
      Predicate{ Or( Eq("a","1"), And(Eq("b","2"),Eq("c","3")) ) } }

    assert { Predicate.from_url_part("(a=1|b=2)&c=3") == 
      Predicate{ And( Or(Eq("a","1"),Eq("b","2")), Eq("c","3") ) } }
  end

end