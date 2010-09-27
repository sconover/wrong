require "./test/test_helper"
require "wrong/adapters/minitest"

describe "a helper for rescuing errors" do
  
  class RedError < StandardError; end
  class BlueError < StandardError; end
  
  it "returns the error that was raised" do
    assert{ rescuing{raise RedError.new}.is_a?(RedError) }
  end

  it "returns nil if nothing was raised" do
    assert{ rescuing{"x"}.nil? }
  end
  
end
