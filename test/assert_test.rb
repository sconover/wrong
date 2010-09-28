require "./test/test_helper"
require "wrong/assert"

describe "basic assert features" do

  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end

  describe "pass/fail basics" do
    it "passes when the result is true.  deny does the reverse" do
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
        assert e.message =~ /^the sky should be blue: /
      end

      it "gives a meaningful error when passed no block" do
        e = get_error {
          @m.assert(2+2 == 5)
        }
        assert e.message =~ /a block/
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
        assert e.message =~ /^the sky should not be blue: /
      end
    end
  end
end

describe "advanced assert features" do
  include Wrong::Assert

  def assert_many(*procs)
    failures = []
    procs.each do |proc|
      begin
        assert(nil, 3, &proc)
      rescue => e
        failures << e
      end
    end
    assert { failures.empty? }
  end

  it "is possible (but not advisable) to define procs in different places from the assert call" do
    x = 10
    e = get_error do
      assert_many(lambda { x == 10 })
      assert_many(lambda { x > 10 })
    end

    assert { e.message =~ /^Expected failures.empty\?/ }
    assert { e.message =~ /x is 10/ }
  end

  xit "can parse a here doc defined inside the block" do
    # todo: test in Chunk too
    assert { "123\n456" == <<-TEXT
123
456
    TEXT
    }
  end

  xit "can parse a here doc defined outside the block" do
    # todo: test in Chunk too
    assert { "123\n456" == <<-TEXT }
123
456
    TEXT
  end

end
