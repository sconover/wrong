puts "RUBY_VERSION=#{RUBY_VERSION}"

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

predicated_project_dir = File.expand_path("../predicated")
if File.exist?(predicated_project_dir) # if predicated project is a sibling of this project
  puts "using predicated from #{predicated_project_dir}"
  $LOAD_PATH.unshift "#{predicated_project_dir}/lib"
  require "predicated"
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
