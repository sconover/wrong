require "./test/test_helper"

require "test/unit"

#require "wrong/assert"
require "wrong/adapters/test_unit"

# get rid of atrocious Test::Unit color scheme (gray on green = puke)
Test::Unit::AutoRunner.setup_option do |auto_runner, opts|
  auto_runner.runner_options[:use_color] = false
end

class MyFailingAssertTest <  Test::Unit::TestCase

  def test_wrong_assert_and_deny_are_available_to_test_unit_tests
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
    assert{ failures.first.long_display.include?("Expected (1 == 2)") }
    
    result = Test::Unit::TestResult.new
    failures = result.instance_variable_get("@failures".to_sym)
    my_failing_deny_test.new("test_fail").run(result) {|started, name| }
    assert{ failures.length==1 }
    assert{ failures.first.long_display.include?("Didn't expect (1 == 1)") }
  end

  def test_passes_asserts_with_no_block_up_to_the_frameworks_assert_method
    e = rescuing { assert(1 == 2) }
    assert { e.message == "<false> is not true." }

    e = rescuing { assert(1 == 2, "black is white") }
    assert { e.message == "black is white.\n<false> is not true." }
  end

  def test_passes_denys_with_no_block_up_to_the_frameworks_assert_method
    e = rescuing { deny(2 + 2 == 4) }
    assert { e.message == "<false> is not true." }

    e = rescuing { deny(2 + 2 == 4, "up is down") }
    assert { e.message == "up is down.\n<false> is not true." }
  end
end
