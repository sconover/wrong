require "./test/test_helper_with_wrong"

require "predicated/from/xml"
require "predicated/to/xml"
include Predicated

regarding "convert xml back and forth" do

  test "string to predicate to string" do
    assert{ Predicate.from_xml("<equal><left>a</left><right>3</right></equal>").to_xml == 
              "<equal><left>a</left><right>3</right></equal>" }
    
    complex_xml = %{
       <or>
        <and>
          <equal><left>a</left><right>1</right></equal>
          <equal><left>b</left><right>2</right></equal>
        </and>
        <equal><left>c</left><right>3</right></equal>
      </or>
    }
              
    assert{ Predicate.from_xml(complex_xml).to_xml.gsub(/\s/, "") == 
              complex_xml.gsub(/\s/, "") }
  end
  
  test "predicate to string to predicate.  note the loss of type fidelity." do
    assert{ Predicate.from_xml(Predicate{ Eq("a",3) }.to_xml) == Predicate{ Eq("a",'3') } }
    
    assert{ Predicate.from_xml(Predicate{ Or(And(Eq("a",1),Eq("b",2)), Eq("c",3)) }.to_xml) ==
              Predicate{ Or(And(Eq("a",'1'),Eq("b",'2')), Eq("c",'3')) } }
  end

end