require "./test/test_helper"
require "wrong"
require "wrong/d"
require "wrong/adapters/minitest"

describe "d" do
  include Wrong::D

  it "prints its argument's name and its value" do
    x = 5
    output = capturing do
      d { x }
    end
    assert { output == "x is 5\n" }
  end

  it "inspects the value" do
    x = "one\ttwo"
    output = capturing do
      d { x }
    end
    assert { output == "x is \"one\\ttwo\"\n" }
  end

  it "pretty-prints the value" do
    begin
      Wrong::Terminal.width = 20
      x = ["a" * 10, "b" * 10]
      output = capturing do
        d { x }
      end
      assert { output ==
        "x is [\"aaaaaaaaaa\",\n \"bbbbbbbbbb\"]\n"
      }
    ensure
      Wrong::Terminal.width = nil
    end
  end

  it "works on an expression" do
    x = 5
    output = capturing do
      d { x + 2 }
    end
    assert { output == "(x + 2) is 7\n" }
  end

  it "works even if it's not the only thing on the line" do
    x = 8
    output = capturing do
      x; d { x }
    end
    assert { output == "x is 8\n" }
  end

  it "works even if it's nested in another block on the same line" do
    x = 8
    output = capturing do
      assert { d { x }; true }
    end
    assert { output == "x is 8\n" }
  end

  it "works when called on an extending module" do
    module Something
      extend Wrong::D
    end
    x = 99
    output = capturing { Something.d { x }}
    assert { output == "x is 99\n" }
  end

  it "works when called on the D module" do
    x = 9
    output = capturing {
      Wrong::D.d { x }
    }
    assert { output == "x is 9\n" }
  end

  it "takes an optional message string" do
    output = capturing {
      Wrong::D.d("basic math") { 2 + 2 }
    }
    assert { output == "basic math: (2 + 2) is 4\n" }
  end

  it "takes a bunch of optional messages" do
    output = capturing {
      Wrong::D.d(2, "plus", :two) { 2 + 2 }
    }
    assert { output == "2, plus, two: (2 + 2) is 4\n" }
  end

end
