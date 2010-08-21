dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"
$LOAD_PATH.unshift "../wrong/lib"
require "rubygems"
require "minitest/spec"
require "pp"

#DO NOT REQUIRE WRONG IN HERE
#The circularity between projects will cause certain tests to not work.

class Color
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Color) && @name == other.name
  end

  def to_s
    "name:#{@name}"
  end
end

def run_suite(wildcard)
  #simple way to make sure requires are isolated
  result = Dir[wildcard].collect{|test_file| system("ruby #{test_file}") }.uniq == [true]
  puts "suite " + (result ? "passed" : "FAILED")
  exit(result ? 0 : 1)
end

class MiniTest::Unit::TestCase
  
  def assert_raise(exception_info_regex)
    begin
      yield
    rescue Exception => e
      assert{ exception_info_regex =~ "#{e.class.name} #{e.message}" }
    end
  end
  
end

module Kernel
  alias_method :regarding, :describe
  
  def xregarding(str)
    puts "x'd out 'regarding \"#{str}\"'"
  end
end

class MiniTest::Spec
  class << self
    alias_method :test, :it
    
    def xtest(str)
      puts "x'd out 'test \"#{str}\"'"
    end

  end
end

MiniTest::Unit.autorun
