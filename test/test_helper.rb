dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"
$LOAD_PATH.unshift "../predicated/lib"
require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "pp"

def get_error
  error = nil
  begin
    yield
  rescue Exception, RuntimeError => e
    error = e
  end
  error
end

class MiniTest::Unit::TestCase
end

module Kernel
  alias_method :regarding, :describe
  
  def xregarding(str)
    puts "x'd out 'regarding \"#{str}\"'"
  end
end

class MiniTest::Spec
  include MiniTest::Assertions
  
  class << self
    alias_method :test, :it
    
    def xtest(str)
      puts "x'd out 'test \"#{str}\"'"
    end

  end
end

MiniTest::Unit.autorun