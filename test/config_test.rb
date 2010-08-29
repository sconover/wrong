require "./test/test_helper"
require "wrong/config"
require "wrong/assert"
require "wrong/message/string_diff"


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

  describe "adding aliases for assert" do
    before do
      Wrong.config.alias_assert(:is)
    end

    it "succeeds" do
      is { 2 + 2 == 4 }
    end

    it "fails" do
      e = rescuing {
        is("math is hard") { 2 + 2 == 5 }
      }
      expected = <<-FAIL
math is hard: Expected ((2 + 2) == 5), but 4 is not equal to 5
    (2 + 2) is 4
      FAIL
      assert { e.message == expected }
    end

    it "doesn't keep aliasing the same word" do
      Wrong.config.alias_assert(:is)
      Wrong.config.alias_assert(:is)
      assert { Wrong.config.assert_method_names == [:assert, :is] } 
    end
  end

  describe "adding aliases for deny" do
    before do
      Wrong.config.alias_deny(:aint)
    end

    it "succeeds" do
      aint { 2 + 2 == 5 }
    end

    it "fails" do
      e = rescuing {
        aint("math is hard") { 2 + 2 == 4 }
      }
      expected = <<-FAIL
math is hard: Didn't expect ((2 + 2) == 4), but 4 is equal to 4
    (2 + 2) is 4
      FAIL
      assert { e.message == expected }
    end

    it "doesn't keep aliasing the same word" do
      Wrong.config.alias_deny(:aint)
      Wrong.config.alias_deny(:aint)
      assert { Wrong.config.deny_method_names == [:deny, :aint] }
    end

  end

end
