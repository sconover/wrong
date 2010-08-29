require "./test/test_helper"

require "wrong/assert"
require "wrong/adapters/minitest"

describe "a tool for rescuing errors" do
  
  class RedError < StandardError; end
  class BlueError < StandardError; end
  
  it "catch the error and assert on it" do
    assert{ rescuing{raise RedError.new}.is_a?(RedError) }
    assert{ rescuing{"x"}.nil? }
  end
  
end
