require "./test/test_helper"
require "wrong/assert"
require "wrong/message/array_diff"
require "wrong/adapters/minitest"

apropos "when you're comparing strings and they don't match, show me the diff message" do
  
  def assert_string_diff_message(block, str)
    assert{catch_raise{assert(&block)}.message.include?(str)}
  end
  
  test "don't attempt to do this if the assertion is not of the form a_array==b_array" do
    deny{catch_raise{assert{[1]==2}}.message.include?("diff")}
    deny{catch_raise{assert{nil==[1]}}.message.include?("diff")}
  end

  test "simple" do
    assert{catch_raise{assert{["a"]==["b"]}}.message.include?("diff")}
    
    assert_string_diff_message(proc{["a", "b"]==["a", "c", "c"]}, %{
["a", "b"]
["a", "c", "c"]
      ^    ^   
})
  end
  
  test "elements align properly" do
    assert_string_diff_message(proc{["a", "b", "c"]==["a", "cccc", "c"]}, %{
["a", "b"   , "c"]
["a", "cccc", "c"]
      ^           
})

    assert_string_diff_message(proc{["a", "b", "c", "d"]==["a", "cccc", "xxx", "d"]}, %{
["a", "b"   , "c"  , "d"]
["a", "cccc", "xxx", "d"]
      ^       ^          
})
  end

  test "different primitive types" do
    assert_string_diff_message(proc{[1, true]==[2, true, nil]}, %{
[1, true]
[2, true, nil]
 ^        ^   
})
  end

  test "2d array - just inspects the inner array like it would any other element" do
    assert{[1, [2, 3]]==[1, [2, 3]]}
    assert_string_diff_message(proc{[1, [2]]==[1, [2, 3]]}, %{
[1, [2]   ]
[1, [2, 3]]
    ^      
})

  end
  
end