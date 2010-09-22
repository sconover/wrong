dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

if File.exist?("../predicated/lib")
  $LOAD_PATH.unshift "../predicated/lib" 
else
  $LOAD_PATH.unshift "#{dir}/../lib/predicated/lib"
end

require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "pp"

# yes, this does look a lot like Wrong::Assert#rescuing :-)
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
  def xdescribe(str)
    puts "x'd out describe \"#{str}\""
  end
end

class MiniTest::Spec
  include MiniTest::Assertions
  
  class << self
    def xit(str)
      puts "x'd out test \"#{str}\""
    end
  end
end

# dummy class for use by tests
class Color
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Color) && @name == other.name
  end

  def inspect
    "Color:#{@name}"
  end
end

MiniTest::Unit.autorun
