require "test/test_helper"

require "test/unit"

require "wrong/assert"
require "wrong/adapters/test_unit"

class MyFailingAssertTest <  Test::Unit::TestCase
  
  def test_strip_out_other_assert_methods
    #because they call into assert and we're redfining that method so it's potentially confusing
    
    begin
      Class.new(Test::Unit::TestCase).assert_equal(1, 1)
    rescue StandardError => e
      e.message.include?("has been disabled")
    end
  end
  
  
  def test_assert_and_deny_are_available_to_test_unit_tests
    my_failing_assert_test = Class.new(Test::Unit::TestCase)
    my_failing_assert_test.class_eval do
      def test_fail
        assert{1==2}
      end
    end
    
    my_failing_deny_test = Class.new(Test::Unit::TestCase)
    my_failing_deny_test.class_eval do
      def test_fail
        deny{1==1}
      end
    end
    
    result = Test::Unit::TestResult.new
    my_failing_assert_test.new("test_fail").run(result) {|started, name| }
    #I can do without all the TU Listener business, thank you
    failures = result.instance_variable_get("@failures".to_sym)
    assert{ failures.length==1 }
    assert{ failures.first.long_display.include?("1 is not equal to 2") }
    
    result = Test::Unit::TestResult.new
    failures = result.instance_variable_get("@failures".to_sym)
    my_failing_deny_test.new("test_fail").run(result) {|started, name| }
    assert{ failures.length==1 }
    assert{ failures.first.long_display.include?("1 is equal to 1") }
  end
  
end
