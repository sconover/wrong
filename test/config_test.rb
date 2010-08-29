require "./test/test_helper"
require "wrong/config"
require "wrong/assert"

describe Wrong::Config do

  # hope this doesn't blow up, but I'll try to use Wrong to test the Config object
  include Wrong::Assert

  before do
    Wrong.config.clear
  end

  it "singleton" do
    c = Wrong.config
    assert { c.is_a?(Wrong::Config) }
    c2 = Wrong.config
    assert { c.object_id == c2.object_id }
  end

#  it "reading from a .wrong file"

  it "getting an undeclared setting" do
    assert { Wrong.config[:foo].nil? }
  end

  it "setting and getting" do
    Wrong.config[:foo] = "bar"
    assert { Wrong.config[:foo] == "bar" }
  end
  
end
