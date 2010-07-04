require "test/test_helper"

require "wrong/assert"
require "wrong/minitest"

apropos "a tool for rescuing errors" do
  
  class RedError < StandardError; end
  class BlueError < StandardError; end
  
  test "catch the error and assert on it" do
    assert{ catch_raise{raise RedError.new}.is_a?(RedError) }
    assert{ catch_raise{"x"}.nil? }
  end
  
end