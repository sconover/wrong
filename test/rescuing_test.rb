require "./test/test_helper"

require "wrong/assert"
require "wrong/adapters/minitest"

regarding "a tool for rescuing errors" do
  
  class RedError < StandardError; end
  class BlueError < StandardError; end
  
  test "catch the error and assert on it" do
    assert{ rescuing{raise RedError.new}.is_a?(RedError) }
    assert{ rescuing{"x"}.nil? }
  end
  
end
