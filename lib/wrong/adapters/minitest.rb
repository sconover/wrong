require "wrong/assert"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  def failure_class
    MiniTest::Assertion
  end
end
