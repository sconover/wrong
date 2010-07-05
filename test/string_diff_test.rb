require "test/test_helper"
require "wrong/assert"
require "wrong/string_diff"
require "wrong/minitest"

apropos "when you're comparing strings and they don't match, show me the diff message" do
  
  def assert_string_diff_message(block, str)
    assert{catch_raise{assert(&block)}.message.include?(str)}
  end
  
  test "don't attempt to do this if the assertion is not of the form a_string==b_string" do
    deny{catch_raise{assert{1==2}}.message.include?("diff")}
    deny{catch_raise{assert{"a"==2}}.message.include?("diff")}
    deny{catch_raise{assert{1=="a"}}.message.include?("diff")}
    deny{catch_raise{assert{nil=="a"}}.message.include?("diff")}
  end

  test "simple" do
    assert{catch_raise{assert{"a"=="b"}}.message.include?("diff")}
    
    assert_string_diff_message(proc{"ab"=="acc"}, %{
ab
 ^ 
acc
 ^^
})
  end

  test "whitespace" do
    assert_string_diff_message(proc{"a\nb"=="a\ncc"}, %{
a\\nb
  ^ 
a\\ncc
  ^^
})

    assert_string_diff_message(proc{"a\tb"=="a\tcc"}, %{
a\\tb
  ^ 
a\\tcc
  ^^
})
    assert_string_diff_message(proc{"a\rb"=="a\rcc"}, %{
a\\rb
  ^ 
a\\rcc
  ^^
})

  end

  
end