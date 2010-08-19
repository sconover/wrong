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

  puts ""
  puts error

  error
end

class MiniTest::Unit::TestCase
  
end

module Kernel
  alias_method :apropos, :describe
  
  def xapropos(str)
    puts "x'd out 'apropos \"#{str}\"'"
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
