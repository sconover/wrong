require "./test/test_helper_with_wrong"

require "predicated/predicate"
include Predicated

regarding "you can flip through the predicate tree, like any enumerable.  a list of ancestors of each node are provided" do
  
  test "simple" do
    assert { Predicate { Eq(1, 2) }.to_a == [[Predicate { Eq(1, 2) }, []]] }
  end
    
  test "complex" do
    the_top = Predicate { And(Eq(1, 2), Or(Eq(3, 4), Eq(5, 6))) }
    the_or = Predicate { Or(Eq(3, 4), Eq(5, 6)) }
    assert { the_top.to_a == 
       [
        [the_top, []],
        [Predicate { Eq(1, 2) }, [the_top]],
        [Predicate { Or(Eq(3, 4), Eq(5, 6)) }, [the_top]],
        [Predicate { Eq(3, 4) }, [the_top, the_or]],
        [Predicate { Eq(5, 6) }, [the_top, the_or]]
       ] 
     }
  end

  test "not" do
    the_top = Predicate { Not(Eq(1, 2)) }
    assert {  the_top.to_a == [[the_top, []], [Predicate { Eq(1, 2) }, [the_top]]] }
  end
    
end

