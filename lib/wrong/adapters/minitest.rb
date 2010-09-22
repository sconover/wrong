require "wrong/assert"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  def failure_class
    MiniTest::Assertion
  end

  def assert(*args, &block)
    self._assertions += 1 unless block.nil?
    super
  end
  
  def deny(*args, &block)
    self._assertions += 1 unless block.nil?
    super
  end
end
