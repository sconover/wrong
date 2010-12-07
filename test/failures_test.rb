require "./test/test_helper"

require "wrong/assert"
require "wrong/sexp_ext"

describe "failures" do

  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end

  describe "simple" do

    it "raw boolean assert failure" do
      error = get_error { @m.assert { false } }
      assert_match "false", error.message
    end

    it "raw boolean deny failure" do
      error = get_error {
        @m.deny { true }
      }
      assert_match "true", error.message
    end

    it "equality failure" do
      assert_match "Expected (1 == 2)", get_error {
        @m.assert { 1==2 }
      }.message
      assert_match "Didn't expect (1 == 1)", get_error {
        @m.deny { 1==1 }
      }.message
    end

    it %{multiline assert block shouldn't look any different
           than when there everything is on one line} do
      assert_match("Expected (1 == 2)", get_error {
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
      assert_match "Expected (a == 2), but", get_error {
        @m.assert { a==2 }
      }.message
      assert_match "Didn't expect (a == 1)", get_error {
        @m.deny { a==1 }
      }.message
    end
  end

  # describe "the assert block has many statements" do
    # this is not true anymore -- should it be?
    # it "only pay attention to the final statement" do
    #   assert_match("Expected (1 == 2)", get_error {
    #     @m.assert {
    #       a = "aaa"
    #       b = 1 + 2
    #       c = ["foo", "bar"].length / 3
    #       if a=="aaa"
    #         b = 4
    #       end; 1==2
    #     }
    #   }.message)
    # end

    # this raises an error trying to evaluate 'a'
    it "works even if the assertion is based on stuff set previously in the block"
     # do
     #      assert_match(/Expected.*\(a == "bbb"\)/, get_error {
     #        @m.assert {
     #          a = "aaa"
     #          a=="bbb"
     #        }
     #      }.message)
     #    end

  describe "array comparisons" do
    it "basic" do
      assert_match 'Expected ([1, 2] == ["a", "b"])', get_error {
        @m.assert { [1, 2]==%w{a b} }
      }.message
    end
  end

  describe "hash comparisons" do
    it "basic" do
      e = get_error {
        @m.assert { {1=>2}=={"a"=>"b"} }
      }
      # this is weird; it should realize those details are truisms  -- must be a whitespace thing
      expected =<<-TEXT
Expected ({ 1 => 2 } == { "a" => "b" }), but
    { 1 => 2 } is {1=>2}
    { "a" => "b" } is {"a"=>"b"}
      TEXT

      assert_equal expected, e.message
    end
  end

end
