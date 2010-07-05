require "wrong/assert"

class Test::Unit::TestCase
  
  
  include Wrong::Assert
  
  Wrong::Assert.disable_existing_assert_methods(self)
  
  def failure_class
    Test::Unit::AssertionFailedError
  end
end