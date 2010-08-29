require "wrong/assert"

class Test::Unit::TestCase
  include Wrong::Assert

  def failure_class
    Test::Unit::AssertionFailedError
  end
end
