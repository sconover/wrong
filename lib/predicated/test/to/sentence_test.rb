require "./test/test_helper_with_wrong"

require "predicated/to/sentence"
include Predicated

regarding "convert a predicate to an english sentence" do
  
  after do
    Operation.reset_verb_phrases
  end
  
  test "operations" do
    assert { Predicate{ Eq("a",1) }.to_sentence == '"a" is equal to 1' }
    assert { Predicate{ Gt("a",1) }.to_sentence == '"a" is greater than 1' }
    assert { Predicate{ Lt("a",1) }.to_sentence == '"a" is less than 1' }
    assert { Predicate{ Gte("a",1) }.to_sentence == '"a" is greater than or equal to 1' }
    assert { Predicate{ Lte("a",1) }.to_sentence == '"a" is less than or equal to 1' }

    assert { Predicate{ Eq("a",1) }.to_negative_sentence == '"a" is not equal to 1' }
    assert { Predicate{ Gt("a",1) }.to_negative_sentence == '"a" is not greater than 1' }
    assert { Predicate{ Lt("a",1) }.to_negative_sentence == '"a" is not less than 1' }
    assert { Predicate{ Gte("a",1) }.to_negative_sentence == '"a" is not greater than or equal to 1' }
    assert { Predicate{ Lte("a",1) } .to_negative_sentence == '"a" is not less than or equal to 1' }
  end
  
  test "primitive types" do
    assert { Predicate{ Eq("a",1) }.to_sentence == '"a" is equal to 1' }
    assert { Predicate{ Eq("a",nil) }.to_sentence == '"a" is equal to nil' }
    assert { Predicate{ Eq("a",true) }.to_sentence == '"a" is equal to true' }
    assert { Predicate{ Eq("a",3.14) }.to_sentence == '"a" is equal to 3.14' }
  end

  test "not" do
    assert { Predicate{ Not(Eq("a",1)) }.to_sentence == '"a" is not equal to 1' }
    assert { Predicate{ Not(Eq("a",1)) }.to_negative_sentence == '"a" is equal to 1' }
  end
  
  test "complex types" do
    assert { Predicate{ Eq([1,2],{3=>4}) }.to_sentence == "[1, 2] is equal to {3=>4}" }
  end
  
  test "default verb phrases for unknown methods (which are awkward/ESL-ish)" do
    assert { Predicate{ Call("abc", :exclude?, "bc") }.to_sentence == 
      '"abc" is exclude "bc"' }

    assert { Predicate{ Call("abc", :exclude?, "bc") }.to_negative_sentence == 
      '"abc" is not exclude "bc"' }
      
    assert { Predicate{ Call("abc", :friends_with?, "bc") }.to_sentence == 
      '"abc" is friends with "bc"' }
  end
  
  test "register methods and their verb phrases" do
    Operation.register_verb_phrase(:exclude?, "excludes", "does not exclude")
    assert { Predicate{ Call("abc", :exclude?, "bc") }.to_sentence == 
      '"abc" excludes "bc"' }

    assert { Predicate{ Call("abc", :exclude?, "bc") }.to_negative_sentence == 
      '"abc" does not exclude "bc"' }
  end
  
  test "some other common methods have sensible verb phrases by default" do
    assert { Predicate{ Call("abc", :include?, 'bc') }.to_sentence == '"abc" includes "bc"' }
    assert { Predicate{ Call("abc", :include?, 'bc') }.to_negative_sentence == '"abc" does not include "bc"' }

    s = Predicate{ Call("abc", :is_a?, String) }.to_sentence
    assert { s == '"abc" is a String' }
    assert { Predicate{ Call("abc", :is_a?, String) }.to_negative_sentence == '"abc" is not a String' }
  end
  
  test "nothing on the far side" do
    assert { Predicate{ Call("abc", :nil?) }.to_sentence == '"abc" is nil' }
    assert { Predicate{ Call("abc", :nil?) }.to_negative_sentence == '"abc" is not nil' }
  end
  
  test "simple and + or" do
    assert { Predicate{ And(Eq("a", 1),Eq("b", 2)) }.to_sentence == 
              '"a" is equal to 1 and "b" is equal to 2' }

    assert { Predicate{ Or(Eq("a", 1),Eq("b", 2)) }.to_sentence == 
              '"a" is equal to 1 or "b" is equal to 2' }

    assert { Predicate{ And(Eq("a", 1),Eq("b", 2)) }.to_negative_sentence == 
              'This is not true: "a" is equal to 1 and "b" is equal to 2' }

    assert { Predicate{ Or(Eq("a", 1),Eq("b", 2)) }.to_negative_sentence == 
              'This is not true: "a" is equal to 1 or "b" is equal to 2' }
  end

end
