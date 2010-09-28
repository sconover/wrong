require "./test/test_helper"
require "wrong"

describe "the Wrong module" do

  class Client
    include Wrong
  end

  describe "by itself" do
    it "gets the assert method" do
      Wrong.assert { true }
    end

    it "gets the deny method" do
      Wrong.deny { false }
    end

    it "gets the capturing method" do
      value = Wrong.capturing { puts "ok" }
      assert value == "ok\n"
    end

    it "gets the rescuing method" do
      value = Wrong.rescuing { raise "uh-oh" }
      assert value.message == "uh-oh"
    end

  end

  describe "when included" do
    it "gets the assert method" do
      Client.new.assert { true }
    end

    it "gets the deny method" do
      Client.new.deny { false }
    end

    it "gets the capturing method" do
      value = Client.new.capturing { puts "ok" }
      assert value == "ok\n"
    end

    it "gets the rescuing method" do
      value = Client.new.rescuing { raise "uh-oh" }
      assert value.message == "uh-oh"
    end

    it "adds #close_to? to Float" do
      assert 1.0.respond_to?(:close_to?)
    end

    it "adds #d to a global namespace" do
      x = 5
      output = Wrong.capturing { d { x } }
      Wrong.assert { output == "x is 5\n" }
    end
  end
end
