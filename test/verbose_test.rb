here = File.dirname(__FILE__)

require "#{here}/test_helper"
require "wrong/assert"
require "wrong/helpers"
require "wrong/d"
require "wrong/rainbow"

describe "verbose assert" do
  
  include Wrong::Helpers
  include Wrong::D
  
  before do
    @m = Module.new do
      extend Wrong::Assert
    end
    Wrong.config.verbose
    @color_enabled = Sickill::Rainbow.enabled
  end
  
  after do
    Wrong.config[:verbose] = nil
    Wrong.config[:color] = nil
    Sickill::Rainbow.enabled = @color_enabled
  end

  it "sets the verbose flag" do
    assert Wrong.config[:verbose]
  end
  
  it "prints the contents of a successful assert" do
    out = capturing {
      @m.assert { 2 + 2 == 4 }
    }
    assert_equal "((2 + 2) == 4)\n", out
  end

  it "prints the message and contents of a successful assert" do
    out = capturing {
      @m.assert("basic math") { 2 + 2 == 4 }
    }
    assert_equal "basic math: ((2 + 2) == 4)\n", out
  end
  
  it "prints in color" do
    Wrong.config.color
    Sickill::Rainbow.enabled = true
    out = capturing {
      @m.assert { 2 + 2 == 4 }
    }
    colored = ["((2 + 2) == 4)".color(:green), "\n"].join
    assert_equal colored, out
  end

  it "prints in color with an explanation" do
    Wrong.config.color
    Sickill::Rainbow.enabled = true
    out = capturing {
      @m.assert("basic math") { 2 + 2 == 4 }
    }
    colored = ["basic math".color(:blue), ": ", "((2 + 2) == 4)".color(:green), "\n"].join
    assert_equal colored, out
  end

end
