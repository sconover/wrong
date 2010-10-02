require "./test/test_helper"
require "wrong/assert"
require "wrong/helpers"
require "wrong/message/array_diff"
require "wrong/adapters/minitest"

describe "when you're comparing strings and they don't match, show me the diff message" do

  def assert_string_diff_message(first_array, second_array, expected_error_message)
    e = rescuing {
      Wrong.assert { first_array == second_array }
    }
    assert {
      e.message.include?(expected_error_message)
    }
  end

  it "don't attempt to do this if the assertion is not of the form a_array==b_array" do
    deny {
      rescuing {
        assert { [1]==2 }
      }.message.include?("diff")
    }
    deny {
      rescuing {
        assert { nil==[1] }
      }.message.include?("diff")
    }
  end

  it "simple" do
    e = rescuing {
      assert { ["a"]==["b"] }
    }
    assert {
      e.message.include?("diff")
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
