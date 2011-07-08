require "wrong"

def wrong_adapter_failure(why)
  $stderr.puts why
  $stderr.puts <<-TEXT
Make sure to use Bundler or Rubygems to load the test-unit gem. For example:
  require 'rubygems'
  gem 'test-unit'
  require 'test/unit'
  require 'wrong/adapters/test_unit'
  TEXT
  exit 1
end

if Test::Unit.const_defined? :TEST_UNIT_IMPLEMENTATION
  wrong_adapter_failure "You are using MiniTest's compatibility layer, not the real Test::Unit."
end

begin
  require "test/unit/version"
  v = Test::Unit::VERSION
  wrong_adapter_failure "Test::Unit version 2.1.2 or greater required." if v < "2.1.2"

  require 'test/unit/failure'
  Test::Unit::TestResultFailureSupport # this class is only in 2.x, to catch mixups between 1.8's lib and gem versions
rescue Exception => e
  wrong_adapter_failure "You are using an outdated version of Test::Unit."
end

class Test::Unit::TestCase
  include Wrong

  def failure_class
    Test::Unit::AssertionFailedError
  end
end

module Wrong::Assert
  def increment_assertion_count
    @_result.add_assertion if @_result
  end
end
