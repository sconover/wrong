require "wrong/assert"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  def failure_class
    MiniTest::Assertion
  end
  
  def assert(*args, &block)
    self._assertions += 1
    super
  end
end
