dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"
$LOAD_PATH.unshift "../predicated/lib"
require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "pp"

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

MiniTest::Unit.autorun