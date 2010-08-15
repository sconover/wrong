require "./test/test_helper"

require "minitest/spec"
require "minitest/unit"

require "wrong/assert"
require "wrong/adapters/minitest"

regarding "basic assert features" do
  
  regarding "pass/fail basics" do
    test "disables other assert methods" do
      test_case_instance = Class.new(MiniTest::Unit::TestCase).new("x")
      assert{ catch_raise{test_case_instance.assert_equal(1,1)}.
               message.include?("has been disabled") }
    end
    
    test "raises minitest assertion failures" do
      test_case_instance = Class.new(MiniTest::Unit::TestCase).new("x")
      assert{ catch_raise{test_case_instance.assert{1==2}}.is_a?(MiniTest::Assertion)}
    end
    
    test "assert and deny are available to minitest tests" do
      class MyFailingAssertTest <  MiniTest::Unit::TestCase
        def initialize
          super("assert test")
        end
        
        def test_fail
          assert{1==2}
        end
      end
      
      class MyFailingDenyTest <  MiniTest::Unit::TestCase
        def initialize
          super("deny test")
        end
        
        def test_fail
          deny{1==1}
        end
      end
      
      msg = catch_raise{MyFailingAssertTest.new.test_fail}.message
      assert{ "1 is not equal to 2" ==  msg }

      msg = catch_raise{MyFailingDenyTest.new.test_fail}.message
      assert{ "1 is equal to 1" ==  msg }
    end
  
  end
  
end