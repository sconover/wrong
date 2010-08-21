require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

require "predicated/to/xml"
include Predicated

regarding "convert a predicate to an xml string" do
  include CanonicalTransformCases
  
  @to_expectations = {
    "simple operations" => {
      "eq" => "<equal><left>a</left><right>3</right></equal>",
      "gt" => "<greaterThan><left>a</left><right>3</right></greaterThan>",
      "lt" => "<lessThan><left>a</left><right>3</right></lessThan>",
      "gte" => "<greaterThanOrEqualTo><left>a</left><right>3</right></greaterThanOrEqualTo>",
      "lte" => "<lessThanOrEqualTo><left>a</left><right>3</right></lessThanOrEqualTo>"
    },
    "primitive types" => {
      "false" => "<equal><left>a</left><right>false</right></equal>",
      "true" => "<equal><left>a</left><right>true</right></equal>",
      "string" => "<equal><left>a</left><right>yyy</right></equal>"
    },
    "not" => {
      "simple" => "<not><equal><left>a</left><right>true</right></equal></not>"
    },
    "simple and / or" => {
      "and" => %{<and>
                  <equal><left>a</left><right>1</right></equal>
                  <equal><left>b</left><right>2</right></equal>
                </and>}.gsub("\n", "").gsub(" ", ""),
      "or" => %{<or>
                  <equal><left>a</left><right>1</right></equal>
                  <equal><left>b</left><right>2</right></equal>
                </or>}.gsub("\n", "").gsub(" ", "")
    },
    "complex and / or" => {
      "or and" =>  %{<or>
                       <and>
                         <equal><left>a</left><right>1</right></equal>
                         <equal><left>b</left><right>2</right></equal>
                       </and>
                       <equal><left>c</left><right>3</right></equal>
                     </or>}.gsub("\n", "").gsub(" ", "")
    }
  }
  
  create_canonical_tests(@to_expectations) do |predicate|
    predicate.to_xml.gsub("\n", "").gsub(" ", "")
  end
  
  test "pretty printing" do
    assert{ 
      Predicate{ Or(And(Eq("a", 1),Eq("b", 2)), Not(Eq("c",3))) }.to_xml ==
%{<or>
  <and>
    <equal><left>a</left><right>1</right></equal>
    <equal><left>b</left><right>2</right></equal>
  </and>
  <not>
    <equal><left>c</left><right>3</right></equal>
  </not>
</or>}
    }
  end

  test "characters that need to be encoded" do
    assert{ 
      Predicate{ Eq(%{'"&<>}, %{'"&<>}) }.to_xml ==
        %{<equal><left>&apos;&quot;&amp;&lt;&gt;</left><right>&apos;&quot;&amp;&lt;&gt;</right></equal>}
    }
  end
end