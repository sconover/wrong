require "./test/test_helper"
require "wrong/assert"

describe "basic assert features" do

  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end

  describe "pass/fail basics" do
    it "assert passes when the result is true.  deny does the reverse" do
      @m.assert { true }
      @m.assert { 1==1 }

      @m.deny { false }
      @m.deny { 1==2 }
    end

    it "fails when result is false.  deny does the reverse" do
      get_error {
        @m.assert { false }
      } || fail
      get_error {
        @m.assert { 1==2 }
      } || fail

      get_error {
        @m.deny { true }
      } || fail
      get_error {
        @m.deny { 1==1 }
      } || fail
    end

    class MyError < StandardError;
    end

    describe "assert" do
      it "fails when an error is thrown and bubbles up the error" do
        assert_raises(MyError) { @m.assert { raise MyError.new } }
      end

      it "takes an optional explanation" do
        e = get_error {
          sky = "green"
          @m.assert("the sky should be blue") { sky == "blue" }
        }
        assert e.message =~ /^the sky should be blue: /, e.message
      end

      it "gives a meaningful error when passed no block" do
        e = get_error {
          @m.assert(2+2 == 5)
        }
        assert e.message =~ /a block/, e.message
      end
    end

    describe "deny" do
      it "fails when an error is thrown and bubbles up the error" do
        assert_raises(MyError) { @m.deny { raise MyError.new } }
      end

      it "takes an optional explanation" do
        e = get_error {
          sky = "blue"
          @m.deny("the sky should not be blue") { sky == "blue" }
        }
        assert e.message =~ /^the sky should not be blue: /,
               e.message + "\n\t" + e.backtrace.join("\n\t")
      end
    end
  end
end
