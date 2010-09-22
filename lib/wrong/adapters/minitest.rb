require "wrong/assert"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  def failure_class
    MiniTest::Assertion
  end

  def assert(*args)
    if block_given? 
      self._assertions += 1
      super(explanation=args.first, depth=1)
    else
      super
    end
  end

  def deny(*args)
    if block_given? 
      self._assertions += 1
      super(explanation=args.first, depth=1)
    else
      super
    end
  end
end
