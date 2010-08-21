require "./test/test_helper_with_wrong"

require "predicated/evaluate"
include Predicated

regarding "evaluate a predicate as boolean logic in ruby.  change the context by providing and optional binding." do

  regarding "proving out basic operations" do
    test "equals" do
      assert { Predicate { Eq(1, 1) }.evaluate }
      deny   { Predicate { Eq(1, 2) }.evaluate }
    end
  
    test "less than" do
      assert { Predicate { Lt(1, 2) }.evaluate }
      deny   { Predicate { Lt(2, 2) }.evaluate }
      deny   { Predicate { Lt(3, 2) }.evaluate }
    end

    test "greater than" do
      deny   { Predicate { Gt(1, 2) }.evaluate }
      deny   { Predicate { Gt(2, 2) }.evaluate }
      assert { Predicate { Gt(3, 2) }.evaluate }
    end

    test "less than or equal to" do
      assert { Predicate { Lte(1, 2) }.evaluate }
      assert { Predicate { Lte(2, 2) }.evaluate }
      deny   { Predicate { Lte(3, 2) }.evaluate }
    end
  
    test "greater than or equal to" do
      deny   { Predicate { Gte(1, 2) }.evaluate }
      assert { Predicate { Gte(2, 2) }.evaluate }
      assert { Predicate { Gte(3, 2) }.evaluate }
    end
  end

  regarding "comparing values of different data types" do
    test "strings" do
      assert { Predicate { Eq("1", "1") }.evaluate }
      deny   { Predicate { Eq("1", 1) }.evaluate }
      deny   { Predicate { Eq("1", nil) }.evaluate }
    end
  
    test "booleans" do
      assert { Predicate { Eq(true, true) }.evaluate }
      deny   { Predicate { Eq(false, true) }.evaluate }
      
      deny   { Predicate { Eq(false, nil) }.evaluate }
      deny   { Predicate { Eq(true, nil) }.evaluate }
      
      deny   { Predicate { Eq("false", false) }.evaluate }
      deny   { Predicate { Eq("true", true) }.evaluate }
    end
  
    test "numbers" do
      assert { Predicate { Eq(1, 1) }.evaluate }
      assert { Predicate { Eq(1, 1.0) }.evaluate }
      assert { Predicate { Eq(1.0, 1.0) }.evaluate }
      deny   { Predicate { Eq(1, 2) }.evaluate }
      deny   { Predicate { Eq(1, nil) }.evaluate }
    end

    test "objects" do
      assert { Predicate { Eq(Color.new("red"), Color.new("red")) }.evaluate }
      deny   { Predicate { Eq(Color.new("red"), Color.new("BLUE")) }.evaluate }
      deny   { Predicate { Eq(Color.new("red"), 2) }.evaluate }
      deny   { Predicate { Eq(Color.new("red"), "red") }.evaluate }
      deny   { Predicate { Eq(Color.new("red"), nil) }.evaluate }
    end
  end
  
  
  regarding "and" do
    test "left and right must be true" do
      assert { Predicate { And( Eq(1, 1), Eq(2, 2) ) }.evaluate }
      deny   { Predicate { And( Eq(99, 1), Eq(2, 2) ) }.evaluate }
      deny   { Predicate { And( Eq(1, 1), Eq(99, 2) ) }.evaluate }
    end

    test "simple true and false work too" do
      assert { Predicate { And( true, true ) }.evaluate }
      assert { Predicate { And( true, Eq(2, 2) ) }.evaluate }
      deny   { Predicate { And( true, false ) }.evaluate }
      deny   { Predicate { And( Eq(2, 2), false ) }.evaluate }
    end
    
    test "nested" do
      assert { Predicate { And( true, And(true, true) ) }.evaluate }
      deny   { Predicate { And( false, And(true, true) ) }.evaluate }
      deny   { Predicate { And( true, And(true, false) ) }.evaluate }
    end
  end
  
  regarding "or" do
    test "one of left or right must be true" do
      assert { Predicate { Or(true, true) }.evaluate }
      assert { Predicate { Or(true, false) }.evaluate }
      assert { Predicate { Or(false, true) }.evaluate }
      deny   { Predicate { Or(false, false) }.evaluate }
    end
  end  
  
  regarding "not" do
    test "simple negation" do
      assert { Predicate { Not(Eq(3, 2)) }.evaluate }
      deny   { Predicate { Not(Eq(2, 2)) }.evaluate }
    end

    test "complex" do
      assert { Predicate { Not( And(Eq(2, 2),false) ) }.evaluate }
      deny   { Predicate { Not( And(Eq(2, 2),true) ) }.evaluate }
    end
  end  
  
  regarding "evaluate adds a generic 'call' class.  that is, object.message(args)" do
    test "evaluate simple calls" do
      assert { Predicate { Call("abc", :include?, "bc") }.evaluate }
      deny   { Predicate { Call("abc", :include?, "ZZ") }.evaluate }
    end

    test "nil call.  call defaults to no args if none are specified" do
      assert { Predicate { Call(nil, :nil?, []) }.evaluate }
      deny   { Predicate { Call("abc", :nil?, []) }.evaluate }

      assert { Predicate { Call(nil, :nil?) }.evaluate }
      deny   { Predicate { Call("abc", :nil?) }.evaluate }
    end

    test "inspect" do
      assert { Call.new("abc", :include?, "bc").inspect == "Call('abc'.include?('bc'))" }
    end
    
    test "inspect, empty right hand side" do
      assert { Call.new("abc", :nil?).inspect == "Call('abc'.nil?)" }
    end
    
    test "call equality" do
      assert { Call.new("abc", :include?, "bc") == Call.new("abc", :include?, "bc") }
      deny   { Call.new("ZZZ", :include?, "bc") == Call.new("abc", :include?, "bc") }
      deny   { Call.new("abc", :zzz, "bc") == Call.new("abc", :include?, "bc") }
      deny   { Call.new("abc", :include?, "ZZZ") == Call.new("abc", :include?, "bc") }
    end
    

  end  
  
end
