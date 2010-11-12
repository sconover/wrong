require "./test/test_helper"
require "wrong/assert"
require "wrong/helpers"
require "wrong/adapters/minitest"
require "wrong/message/array_diff"

describe "when you're comparing strings and they don't match, show me the diff message" do

  def assert_string_diff_message(first_array, second_array, expected_error_message)
    e = rescuing {
      assert { first_array == second_array }
    }
    assert {
      e.message.include?(expected_error_message.strip)
    }
  end

  it "don't attempt to do this if the assertion is not of the form a_array==b_array" do
    deny {
      rescuing {
        assert { [1]==2 }
      }.message.include?("^")
    }
    deny {
      rescuing {
        assert { nil==[1] }
      }.message.include?("^")
    }
    deny {
      rescuing {
        assert { {:a=>1}==[1] }
      }.message.include?("^")
    }
  end

  it "simple" do
    e = rescuing {
      assert { ["a"]==["b"] }
    }
    assert {
      e.message.include?("^")
    }

    assert_string_diff_message(["a", "b"], ["a", "c", "c"], %{
["a", "b"]
["a", "c", "c"]
      ^    ^
})
  end

  it "elements align properly" do
    assert_string_diff_message(["a", "b", "c"], ["a", "cccc", "c"], %{
["a", "b"   , "c"]
["a", "cccc", "c"]
      ^
})

    assert_string_diff_message(["a", "b", "c", "d"], ["a", "cccc", "xxx", "d"], %{
["a", "b"   , "c"  , "d"]
["a", "cccc", "xxx", "d"]
      ^       ^
})
  end

  it "different primitive types" do
    assert_string_diff_message([1, true], [2, true, nil], %{
[1, true]
[2, true, nil]
 ^        ^
})
  end

  it "2d array - just inspects the inner array like it would any other element" do
    assert { [1, [2, 3]] == [1, [2, 3]] }
    assert_string_diff_message([1, [2]], [1, [2, 3]], %{
[1, [2]   ]
[1, [2, 3]]
    ^
})

  end

end
