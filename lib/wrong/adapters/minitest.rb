require "wrong/assert"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  
  Wrong::Assert.disable_existing_assert_methods(self)
  
  def failure_class
    MiniTest::Assertion
  end
end