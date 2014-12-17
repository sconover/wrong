require "wrong/assert"
require "wrong/helpers"

module Wrong::MiniTestAdapter
  include Wrong::Assert
  include Wrong::Helpers

  def self.minitest_version
    if defined?(MiniTest::VERSION)
      MiniTest::VERSION
    else
      MiniTest::Unit::VERSION
    end
  end

  def self.minitest_base_class
    if minitest_version >= "5.0.0"
      MiniTest::Test
    else
      MiniTest::Unit::TestCase
    end
  end

  def self.minitest_autorun
    require 'minitest/autorun'
    if minitest_version >= "5.0.0"
      MiniTest.autorun
    else
      MiniTest::Unit.autorun
    end
  end

  def minitest_assertion_count
    if Wrong::MiniTestAdapter.minitest_version >= "5.0.0"
      self.assertions
    else
      self._assertions
    end
  end

  def minitest_increment_assertions
    if Wrong::MiniTestAdapter.minitest_version >= "5.0.0"
      self.assertions += 1
    else
      self._assertions +=1
    end
  end

  def failure_class
    MiniTest::Assertion
  end

  if MiniTest::VERSION >= "5.0.6"
    alias_method :_assertions, :assertions
    alias_method :"_assertions=", :"assertions="
  end

  def aver(valence, explanation = nil, depth = 0)
    minitest_increment_assertions
    super(valence, explanation, depth + 1) # apparently this passes along the default block
  end

  $stderr.puts "Loading Wrong adapter for MiniTest #{minitest_version}"
end

Wrong::MiniTestAdapter.minitest_base_class.include Wrong::MiniTestAdapter
