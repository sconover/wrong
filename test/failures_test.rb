require "./test/test_helper"

require "wrong/assert"

describe "failures" do

  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end

  describe "simple" do

    it "raw boolean assert failure" do
      error = get_error { @m.assert { false } }
#      puts error.message
      assert_match "false", error.message
    end

    it "raw boolean deny failure" do
      error = get_error {
        @m.deny { true }
      }
#      puts error.message
      assert_match "true", error.message
    end

    it "equality failure" do
      assert_match "1 is not equal to 2", get_error {
        @m.assert { 1==2 }
      }.message
      assert_match "1 is equal to 1", get_error {
        @m.deny { 1==1 }
      }.message
    end

    it "failure of basic operations" do
      assert_match "1 is not greater than 2", get_error {
        @m.assert { 1>2 }
      }.message
      assert_match "2 is not less than 1", get_error {
        @m.assert { 2<1 }
      }.message
      assert_match "1 is not greater than or equal to 2", get_error {
        @m.assert { 1>=2 }
      }.message
      assert_match "2 is not less than or equal to 1", get_error {
        @m.assert { 2<=1 }
      }.message

      assert_match "2 is greater than 1", get_error {
        @m.deny { 2>1 }
      }.message
      assert_match "1 is less than 2", get_error {
        @m.deny { 1<2 }
      }.message
      assert_match "2 is greater than or equal to 1", get_error {
        @m.deny { 2>=1 }
      }.message
      assert_match "1 is less than or equal to 2", get_error {
        @m.deny { 1<=2 }
      }.message
    end

    it "object failure" do
      assert_match "Color:red is not equal to 2", get_error {
        @m.assert { Color.new("red")==2 }
      }.message
    end

    it %{multiline assert block shouldn't look any different
           than when there everything is on one line} do
      assert_match("1 is not equal to 2", get_error {
        @m.assert {
          1==
            2
        }
      }.message)
    end

  end

  describe "accessing and printing values set outside of the assert" do
    it "use a value in the assert defined outside of it" do
      a = 1
      assert_match "1 is not equal to 2", get_error {
        @m.assert { a==2 }
      }.message
      assert_match "1 is equal to 1", get_error {
        @m.deny { a==1 }
      }.message
    end
  end

  describe "conjunctions (and and or)" do
    it "omit a primary failure message since 'This is not true etc.' is more obscuring than clarifying" do
      m = get_error {
        x = 5
        @m.assert { x == 5 && x != 5}
      }.message
      assert m == "Expected ((x == 5) and (not (x == 5))), but \n    (x == 5) is true\n    x is 5\n    (not (x == 5)) is false\n"
    end
  end

  describe "the assert block has many statements" do
    it "only pay attention to the final statement" do
      assert_match("1 is not equal to 2", get_error {
        @m.assert {
          a = "aaa"
          b = 1 + 2
          c = ["foo", "bar"].length / 3
          if a=="aaa"
            b = 4
          end; 1==2
        }
      }.message)
    end

    it "works even if the assertion is based on stuff set previously in the block" do
      assert_match("\"aaa\" is not equal to \"bbb\"", get_error {
        @m.assert {
          a = "aaa"
          a=="bbb"
        }
      }.message)
    end
  end

  describe "array comparisons" do
    it "basic" do
      assert_match %{[1, 2] is not equal to ["a", "b"]}, get_error {
        @m.assert { [1, 2]==%w{a b} }
      }.message
    end
  end

  describe "hash comparisons" do
    it "basic" do
      assert_match '{1=>2} is not equal to {"a"=>"b"}',
                   get_error {
                     @m.assert { {1=>2}=={"a"=>"b"} }
                   }.message
    end
  end

  describe "methods that result in a boolean.  this might be hard." do
    it "string include" do
      assert_match "\"abc\" does not include \"cd\"", get_error {
        @m.assert { "abc".include?("cd") }
      }.message
      assert_match "\"abc\" includes \"bc\"", get_error {
        @m.deny { "abc".include?("bc") }
      }.message
    end
  end

end
