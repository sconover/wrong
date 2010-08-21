require "./test/test_helper_with_wrong"

require "predicated/predicate"
require "predicated/constrain"
include Predicated

regarding %{constraints are rules about the content and structure of predicates.
          a predicate might violate a constraint} do
            
  before do
    @value_not_equal_to_two =
      Constraint.new(:name => "Value can't be two",
                     :selectors => [Operation],
                     :check_that => proc{|predicate, ancestors| predicate.right!=2})
                     
    @not_more_than_two_levels_deep =
      Constraint.new(:name => "Limited to two levels deep",
                     :check_that => proc{|predicate, ancestors| ancestors.length<=2})
                     
    @one = Predicate{Eq(1,1)}
    @two = Predicate{Eq(2,2)}
    @three = Predicate{Eq(3,3)}
    
    @one_and_three = Predicate{And(Eq(1,1), Eq(3,3))}
    @one_and_two = Predicate{And(Eq(1,1), Eq(2,2))}
    
    @deeply_nested = Predicate{Or(Or(And(Eq(1,1), Eq(3,3)), Eq(4,4)), Eq(5,5))}
  end
  
  test "apply to each predicate - simple" do
    constraints = Constraints.new.add(@value_not_equal_to_two)
    
    assert{ constraints.check(@one).pass? }
    deny  { constraints.check(@two).pass? }
    
    assert{ constraints.check(@one_and_three).pass? }
    deny  { constraints.check(@one_and_two).pass? }
  end
  
  test "apply each to each predicate - many constraints" do
    constraints = 
      Constraints.new.
        add(@value_not_equal_to_two).
        add(@not_more_than_two_levels_deep)

    assert{ constraints.check(@one_and_three).pass? }
    deny  { constraints.check(@one_and_two).pass? }
    
    assert{ constraints.check(@one_and_three).pass? }
    deny  { constraints.check(@deeply_nested).pass? }
  end

  test "equality" do
    one = Constraint.new(:name => "Value can't be two",
                         :selectors => [Operation],
                         :check_that => proc{|predicate, ancestors| predicate.right!=2})
    two = Constraint.new(:name => "Value can't be two",
                         :selectors => [Operation],
                         :check_that => proc{|predicate, ancestors| predicate.right!=2})
    three = Constraint.new(:name => "Some other constraint",
                           :check_that => proc{|predicate, ancestors| false})
                           
    assert{ one == two }
    deny  { one == three }
  end

  test %{result contains information about whether the checks passed, 
         which constraints were violated, 
         along with the offending predicates} do
    constraints = Constraints.new.add(@value_not_equal_to_two)
    
    result = constraints.check(@one)
    assert{ result.pass? }
    assert{ result.violations == {} }
    
    result = constraints.check(Predicate{And(Eq(1,1), And(Eq(2,2), Eq(3,2)))})
    deny  { result.pass? }
    assert{ 
      result.violations == {
        @value_not_equal_to_two => [Equal.new(2,2), Equal.new(3,2)]
      } 
    }
  end

  
end