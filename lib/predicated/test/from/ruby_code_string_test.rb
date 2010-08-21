require "./test/test_helper"

require "predicated/from/ruby_code_string"
include Predicated

regarding "parse a ruby predicate string" do
  
  regarding "basic operations" do
    
    #'Wrong'-style asserts are specifically avoided here.
    #the circularity between the two projects will make you crazy if you're not careful
    
    test "word and" do
      assert_equal Predicate.from_ruby_code_string("1==1 and 2==2"), Predicate{ And(Eq(1,1),Eq(2,2)) }
    end

    test "substitute in from the binding" do
      a = 1
      b = "1"
      c = "c"
      d = Color.new("purple")
      
      assert_equal Predicate.from_ruby_code_string("a==1", binding()), Predicate{ Eq(1,1) }
      assert_equal Predicate.from_ruby_code_string("b==1", binding()), Predicate{ Eq("1",1) }
      assert_equal Predicate.from_ruby_code_string("c==b", binding()), Predicate{ Eq("c","1") }
      assert_equal Predicate.from_ruby_code_string("d==d", binding()), Predicate{ Eq(Color.new("purple"),
                                                              Color.new("purple")) }
      assert_equal Predicate.from_ruby_code_string("d==d", binding()).left, d

      assert_equal Predicate.from_ruby_code_string("a==b && b==c", binding()), 
                Predicate{ And(Eq(1,"1"),Eq("1","c")) }
    end


    test "parens change precedence" do
      assert_equal Predicate.from_ruby_code_string("1==1 || 2==2 && 3==3"),
                   Predicate{ Or( Eq(1,1), And(Eq(2,2),Eq(3,3)) ) }

      assert_equal Predicate.from_ruby_code_string("(1==1 || 2==2) && 3==3"), 
                   Predicate{ And( Or(Eq(1,1),Eq(2,2)), Eq(3,3) ) }
    end
    
    regarding "only pay attention to the final line" do
      #might hate myself one day for this.  but what else does it make sense to do?
      
      test "simple" do
        assert_equal Predicate.from_ruby_code_string("z=2\nb=5\n1==1"), Predicate{ Eq(1,1) }
      end

      test "can make use of variables defined earlier in the block" do
        #might hate myself one day for this.  but what else does it make sense to do?
        assert_equal Predicate.from_ruby_code_string("z=2\nb=5\nz==1"), Predicate{ Eq(2,1) }
      end
    end
    
    test "a call that returns a boolean result" do
      assert_equal Predicate.from_ruby_code_string("'abc'.include?('bc')"), 
                   Predicate{ Call("abc", :include?, "bc") }
      
      color = Color.new("purple")  
      assert_equal Predicate.from_ruby_code_string("color.name.include?('rp')", binding()), 
                   Predicate{ Call("purple", :include?, "rp") }
                   
      assert_equal Predicate.from_ruby_code_string("'abc'.nil?"), 
                   Predicate{ Call("abc", :nil?, nil) }
    end
    
    test "use of instance variables" do
      @a = 1
      
      assert_equal Predicate.from_ruby_code_string("@a==1", binding()), Predicate{ Eq(1,1) }
    end
                            
    test "use of inline assignments" do
      assert_equal Predicate.from_ruby_code_string("(a=2)==1 && a==1"), 
                   Predicate{ And(Eq(2,1), Eq(2,1)) }
    end
                            
    test "use of inline expressions" do
      assert_equal Predicate.from_ruby_code_string("(2*1)==1"), 
                   Predicate{ Eq(2,1) }
                   
      assert_equal Predicate.from_ruby_code_string("[2,1].first==1"), 
                   Predicate{ Eq(2,1) }
    end


  end
  
  regarding "errors" do
    test "can't parse" do
      assert_raises(Racc::ParseError) do 
        Predicate.from_ruby_code_string("bad ruby @@@@@****()(((")
      end
    end  
    
    test "predicates only" do
      assert_raises(Predicated::Predicate::DontKnowWhatToDoWithThisSexpError) do 
        Predicate.from_ruby_code_string("a=1")
      end
    end
  end
end
