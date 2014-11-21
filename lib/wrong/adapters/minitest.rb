require "wrong/assert"
require "wrong/helpers"

class MiniTest::Unit::TestCase
  include Wrong::Assert
  include Wrong::Helpers

  def failure_class
    MiniTest::Assertion
  end

  if MiniTest::VERSION >= "5.0.6"
    alias_method :_assertions, :assertions
    alias_method :"_assertions=", :"assertions="
  end

  def aver(valence, explanation = nil, depth = 0)
    self._assertions += 1 # increment minitest's assert count
    super(valence, explanation, depth + 1) # apparently this passes along the default block
  end
  
end
