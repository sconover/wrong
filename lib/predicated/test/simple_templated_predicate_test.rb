require "./test/test_helper_with_wrong"

require "predicated/simple_templated_predicate"
include Predicated

regarding "simple templated predicates.  the left sides of operations and calls is a common unbound variable" do

  test "operations.  the left side is a placeholder" do
    assert{ SimpleTemplatedPredicate{ Eq(1) }.fill_in(1) == Predicate { Eq(1, 1) } }
    assert{ SimpleTemplatedPredicate{ Lt(2) }.fill_in(1) == Predicate { Lt(1, 2) } }
    assert{ SimpleTemplatedPredicate{ Gt(1) }.fill_in(2) == Predicate { Gt(2, 1) } }
    assert{ SimpleTemplatedPredicate{ Gte(1) }.fill_in(2) == Predicate { Gte(2, 1) } }
    assert{ SimpleTemplatedPredicate{ Lte(2) }.fill_in(1) == Predicate { Lte(1, 2) } }

    assert{ SimpleTemplatedPredicate{ Eq(true) }.fill_in(true) == Predicate { Eq(true, true) } }
  end
  
  test "and, or, not.  just pass on the fill_in" do
    assert{ SimpleTemplatedPredicate{ And(Gt(3),Lt(5)) }.fill_in(4) == Predicate { And(Gt(4,3),Lt(4,5)) } }
    assert{ SimpleTemplatedPredicate{ Or(Gt(3),Lt(5)) }.fill_in(4) == Predicate { Or(Gt(4,3),Lt(4,5)) } }
    assert{ SimpleTemplatedPredicate{ Not(Gt(5)) }.fill_in(4) == Predicate { Not(Gt(4,5)) } }
  end
  
  test "call.  left side is a placeholder" do
    assert{ SimpleTemplatedPredicate{ Call(:include?, "bc") }.fill_in("abc") == 
              Predicate { Call("abc", :include?, "bc") } }

    assert{ SimpleTemplatedPredicate{ Call(:nil?) }.fill_in("abc") == 
              Predicate { Call("abc", :nil?) } }
  end
  
  test "to_s and inspect" do
    assert{ SimpleTemplatedPredicate{ Eq(1) }.inspect == "Eq(1)" }
    assert{ SimpleTemplatedPredicate{ Eq(1) }.to_s == "Eq(1)" }
    
    assert{ SimpleTemplatedPredicate{ Call(:include?, "bc") }.inspect == "Call(include?('bc'))" }
    assert{ SimpleTemplatedPredicate{ Call(:include?, "bc") }.to_s == "Call(include?('bc'))" }
  end
end
