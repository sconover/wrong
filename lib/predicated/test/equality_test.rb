require "./test/test_helper_with_wrong"

require "predicated/predicate"
include Predicated

regarding "prove value equality" do
  
  test "simple" do
    assert { Predicate { Eq(1, 1) } == Predicate { Eq(1, 1) } }
    deny   { Predicate { Eq(1, 1) } == Predicate { Eq(1, 99) } }
  end
  
  test "unary" do
    assert { Predicate { Not(Eq(1, 1)) } == Predicate { Not(Eq(1, 1)) } }
    deny   { Predicate { Not(Eq(1, 1)) } == Predicate { Not(Eq(99, 99)) } }
  end
  
  test "complex" do
    assert { Predicate { And(Eq(1, 1), Or(Eq(2, 2), Eq(3, 3))) } ==
             Predicate { And(Eq(1, 1), Or(Eq(2, 2), Eq(3, 3))) } }
    
    deny   { Predicate { And(Eq(1, 1), Or(Eq(2, 2), Eq(3, 3))) } ==
             Predicate { And(Eq(1, 1), Or(Eq(2, 99), Eq(3, 3))) } }
  end

end

regarding "predicate base class.  not sure I'm happy with the implementation...too tricky" do
  test "all predicates descend from a predicate base class.  it's a marker class" do
    assert{ And.new(Equal.new(1,1),Equal.new(2,2)).is_a?(Predicate) }
  end
end
