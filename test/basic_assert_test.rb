require "test/test_helper"

require "wrong/assert"

regarding "basic assert features" do

  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end

  regarding "pass/fail basics" do
    test "passes when the result is true.  deny does the reverse" do
      @m.assert{true}
      @m.assert{1==1}

      @m.deny{false}
      @m.deny{1==2}
    end

    test "fails when result is false.  deny does the reverse" do
      get_error{
        @m.assert{false}
      } || fail
      get_error{
        @m.assert{1==2}
      } || fail

      get_error{
        @m.deny{true}
      } || fail
      get_error{
        @m.deny{1==1}
      } || fail
    end

    class MyError < StandardError; end

    test "both deny and assert fail when an error is thrown.  bubbles up the error." do
      assert_raises(MyError) { @m.assert{ raise MyError.new } }
      assert_raises(MyError) { @m.deny{ raise MyError.new } }
    end
  end
  
end
