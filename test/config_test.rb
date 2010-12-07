require "./test/test_helper"

require "wrong"
require "wrong/config"
require "wrong/message/string_comparison"

describe Wrong::Config do

  # hope this doesn't blow up, but I'll try to use Wrong to test the Config object
  include Wrong

  before do
    @config = Wrong::Config.new
  end

  it "has magic setters" do
    config = Wrong::Config.new
    config.foo = "bar"
    assert { config[:foo] == "bar" }

    config.baz
    assert { config[:baz] }
  end

  it "reads from a string" do
    config = Wrong::Config.new <<-SETTINGS
cold
flavor = "chocolate"
alias_assert :yum
    SETTINGS
    assert { config[:cold] }
    assert { config[:flavor] == "chocolate" }
    assert { config.assert_method_names.include? :yum }
  end

  describe "Wrong.config" do
    it "is a singleton" do
      c = Wrong.config
      assert { c.is_a?(Wrong::Config) }
      c2 = Wrong.config
      assert { c.object_id == c2.object_id }
    end

    it "reads from a .wrong file in the current directory" do
      wrong_settings = File.read(".wrong")
      assert { wrong_settings != "" }
      assert { Wrong.config[:test_setting] == "xyzzy" }
    end

    it "reads from a .wrong file in a parent directory" do
      wrong_settings = File.read(".wrong")
      Dir.chdir("test") do # move into a subdirectory
        assert { Wrong.load_config[:test_setting] == "xyzzy" }
      end
    end

    it "uses defaults if there is no .wrong file" do
      Dir.chdir("/tmp") do # hopefull there's no .wrong file here or in /
        config = Wrong.load_config
        assert { config[:test_setting] == nil }
      end
    end

  end

  it "getting an undeclared setting" do
    assert { @config[:foo].nil? }
  end

  it "setting and getting" do
    @config[:foo] = "bar"
    assert { @config[:foo] == "bar" }
  end

  describe "adding aliases" do
    after do
      Wrong.config = Wrong::Config.new
    end

    describe "for assert" do
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
math is hard: Expected ((2 + 2) == 5), but
    (2 + 2) is 4
        FAIL
        assert { e.message == expected }
      end

      it "doesn't keep aliasing the same word" do
        @config.alias_assert(:is)
        @config.alias_assert(:is)
        assert { @config.assert_method_names == [:assert, :is] }
      end
    end

    describe "for deny" do
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
math is hard: Didn't expect ((2 + 2) == 4), but
    (2 + 2) is 4
        FAIL
        assert { e.message == expected }
      end

      it "doesn't keep aliasing the same word" do
        @config.alias_deny(:aint)
        @config.alias_deny(:aint)
        assert { @config.deny_method_names == [:deny, :aint] }
      end

    end

  end
end
