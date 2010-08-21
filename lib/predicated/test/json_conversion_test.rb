require "./test/test_helper_with_wrong"

require "predicated/from/json"
require "predicated/to/json"
include Predicated

regarding "convert json back and forth" do

  test "string to predicate to string" do
    assert{ Predicate.from_json_str(%{["a","==",3]}).to_json_str == 
              JSON.pretty_generate(JSON.parse(%{["a","==",3]})) }
    
    complex_json_str = %{
      {
        "or":[
          {"and":[["a","==",1],["b","==",2]]},
          ["c","==",3]
        ]
      }
    }
              
    assert{ Predicate.from_json_str(complex_json_str).to_json_str == 
              JSON.pretty_generate(JSON.parse(complex_json_str)) }
  end
  
  test "predicate to string to predicate" do
    assert{ Predicate.from_json_str(Predicate{ Eq("a",3) }.to_json_str) == Predicate{ Eq("a",3) } }
    
    assert{ Predicate.from_json_str(Predicate{ Or(And(Eq("a",1),Eq("b",2)), Eq("c",3)) }.to_json_str) ==
              Predicate{ Or(And(Eq("a",1),Eq("b",2)), Eq("c",3)) } }
  end

end