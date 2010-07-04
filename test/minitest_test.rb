require "test/test_helper"

require "minitest/spec"
require "minitest/unit"

require "wrong/assert"
require "wrong/minitest"

apropos "basic assert features" do
  
  apropos "pass/fail basics" do
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
      
      msg = get_error{MyFailingAssertTest.new.test_fail}.message
      assert{ "1 is not equal to 2" ==  msg }

      msg = get_error{MyFailingDenyTest.new.test_fail}.message
      assert{ "1 is equal to 1" ==  msg }
    end
  
  end
  
end