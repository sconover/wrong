require "./test/test_helper_with_wrong"

require "predicated/predicate"
require "predicated/from/url_part"
include Predicated

regarding "parse a url part, the result is a parse tree" do
  
  before do
    @parser = TreetopUrlPartParser.new
  end

  regarding "simple operations" do
    
    test "parse" do
      tree = @parser.parse("a=1")
      
      assert{ tree.is_a?(Predicated::TreetopUrlPart::OperationNode) }      
      assert{ [tree.left_text, tree.sign_text, tree.right_text] == ["a", "=", "1"] }
      
      tree = @parser.parse("a>1")
      assert{ [tree.left_text, tree.sign_text, tree.right_text] == ["a", ">", "1"] }
      
      tree = @parser.parse("a<1")
      assert{ [tree.left_text, tree.sign_text, tree.right_text] == ["a", "<", "1"] }

      tree = @parser.parse("a>=1")
      assert{ [tree.left_text, tree.sign_text, tree.right_text] == ["a", ">=", "1"] }

      tree = @parser.parse("a<=1")
      assert{ [tree.left_text, tree.sign_text, tree.right_text] == ["a", "<=", "1"] }
    end
    
    test "...to predicate" do
      assert{ @parser.parse("a=1").to_predicate == Predicate{Eq("a", "1")} }
      assert{ @parser.parse("a>1").to_predicate == Predicate{Gt("a", "1")} }
      assert{ @parser.parse("a<1").to_predicate == Predicate{Lt("a", "1")} }
      assert{ @parser.parse("a>=1").to_predicate == Predicate{Gte("a", "1")} }
      assert{ @parser.parse("a<=1").to_predicate == Predicate{Lte("a", "1")} }
    end

  end

  regarding "simple and" do
    test "parse" do
      tree = @parser.parse("a=1&b=2")
      
      assert{ tree.is_a?(Predicated::TreetopUrlPart::AndNode) }      
      assert{ [[tree.left.left_text, tree.left.sign_text, tree.left.right_text],
               [tree.right.left_text, tree.right.sign_text, tree.right.right_text]] == 
               [["a", "=", "1"], ["b", "=", "2"]] }      
    end
    
    test "...to predicate" do
      assert{ @parser.parse("a=1&b=2").to_predicate == Predicate{ And( Eq("a", "1"),Eq("b", "2") ) } }
    end
  end

  regarding "simple or" do
    test "parse" do
      tree = @parser.parse("a=1|b=2")

      assert{ tree.is_a?(Predicated::TreetopUrlPart::OrNode) }      
      assert{ [[tree.left.left_text, tree.left.sign_text, tree.left.right_text],
               [tree.right.left_text, tree.right.sign_text, tree.right.right_text]] == 
               [["a", "=", "1"], ["b", "=", "2"]] }      
    end
    
    test "...to predicate" do
      assert{ @parser.parse("a=1|b=2").to_predicate == Predicate{ Or( Eq("a", "1"),Eq("b", "2") ) } }
    end
  end
  
  regarding "complex and/or" do
    test "many or's" do
      assert{ @parser.parse("a=1|b=2|c=3").to_predicate == 
        Predicate{ Or( Eq("a", "1"), Or(Eq("b", "2"),Eq("c", "3")) ) } }
    end

    test "many and's" do
      assert{ @parser.parse("a=1&b=2&c=3").to_predicate == 
        Predicate{ And( Eq("a", "1"), And(Eq("b", "2"),Eq("c", "3")) ) } }
    end

    test "mixed and/or" do
      assert{ @parser.parse("a=1|b=2&c=3").to_predicate == 
        Predicate{ Or( Eq("a", "1"), And(Eq("b", "2"),Eq("c", "3")) ) } }

      assert{ @parser.parse("a=1&b=2|c=3").to_predicate == 
        Predicate{ Or( And(Eq("a", "1"),Eq("b", "2")), Eq("c", "3") ) } }
    end
  end

  regarding "parens (force higher precedence)" do
    test "no effect" do
      str = "(a=1|b=2)|c=3"
      assert{ @parser.parse(str).to_predicate == 
        Predicate{ Or( Or(Eq("a", "1"),Eq("b", "2")), Eq("c", "3") ) } }
      
      str = "((a=1|b=2))|c=3"
      assert{ @parser.parse(str).to_predicate == 
        Predicate{ Or( Or(Eq("a", "1"),Eq("b", "2")), Eq("c", "3") ) } }
    end

    test "force precedence" do
      #before
      assert{ @parser.parse("a=1|b=2&c=3").to_predicate == 
        Predicate{ Or( Eq("a", "1"), And(Eq("b", "2"),Eq("c", "3")) ) } }
      
      #after
      assert{ @parser.parse("(a=1|b=2)&c=3").to_predicate == 
        Predicate{ And( Or(Eq("a", "1"),Eq("b", "2")), Eq("c", "3") ) } }
    end
  end

  regarding "not" do
    test "force precedence" do
      assert{ @parser.parse("!(a=1)").to_predicate == 
        Predicate{ Not(Eq("a", "1")) } }
    end
  end

end