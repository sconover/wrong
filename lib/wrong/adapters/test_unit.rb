require "wrong"

class Test::Unit::TestCase
  include Wrong

  def failure_class
    Test::Unit::AssertionFailedError
  end
end
