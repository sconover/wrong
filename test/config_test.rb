require "./test/test_helper"
require "wrong/config"
require "wrong/assert"

regarding Wrong::Config do

  # hope this doesn't blow up, but I'll try to use Wrong to test the Config object
  include Wrong::Assert

  before do
    Wrong.config.clear
  end

  test "singleton" do
    c = Wrong.config
    assert { c.is_a?(Wrong::Config) }
    c2 = Wrong.config
    assert { c.object_id == c2.object_id }
  end

#  test "reading from a .wrong file"

  test "getting an undeclared setting" do
    assert { Wrong.config[:foo].nil? }
  end

  test "setting and getting" do
    Wrong.config[:foo] = "bar"
    assert { Wrong.config[:foo] == "bar" }
  end
  
end
