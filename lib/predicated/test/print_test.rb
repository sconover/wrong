require "./test/test_helper_with_wrong"

require "predicated/predicate"
include Predicated

regarding "a predicate looks nice with you to_s it" do
  test "numbers" do
    assert { Predicate { Eq(1, 1) }.to_s == "Eq(1,1)" }
    assert { Predicate { Lt(1, 2) }.to_s == "Lt(1,2)" }
  end
  
  test "booleans" do
    assert { Predicate { Eq(false, true) }.to_s == "Eq(false,true)" }
  end
  
  test "strings" do
    assert { Predicate { Eq("foo", "bar") }.to_s == "Eq('foo','bar')" }
  end

  test "nil" do
    assert { Predicate { Eq("foo", nil) }.to_s == "Eq('foo',nil)" }
  end

  test "objects" do
    assert {
      Predicate {
        Eq(Color.new("red"), Color.new("blue"))
      }.to_s == "Eq(Color{'name:red'},Color{'name:blue'})"
    }
  end
  
  test "and, or" do
    assert { Predicate { And(true, false) }.to_s == "And(true,false)" }
    assert { Predicate { Or(true, false) }.to_s == "Or(true,false)" }
    
    assert { Predicate { And(Eq(1, 1) , Eq(2, 2)) }.to_s == "And(Eq(1,1),Eq(2,2))" }
    
    assert { Predicate { And(Eq(1, 1), Or(Eq(2, 2), Eq(3, 3))) }.to_s == "And(Eq(1,1),Or(Eq(2,2),Eq(3,3)))" }
  end

  test "not" do
    assert { Predicate { Not(Eq(1, 1)) }.to_s == "Not(Eq(1,1))" }
  end

end

regarding "inspect is like to_s except it's multiline, so you see the tree structure" do
  
  test "an uncomplicated predicate prints on one line" do
    assert { Predicate { Eq(1, 1) }.inspect == "Eq(1,1)" }
  end
  
  test "complex" do
    assert { 
      Predicate { And(Eq(1, 1), Or(Eq(2, 2), Eq(3, 3))) }.inspect == 
%{And(
  Eq(1,1),
  Or(
    Eq(2,2),
    Eq(3,3)
  )
)
}
    }
  end
end
