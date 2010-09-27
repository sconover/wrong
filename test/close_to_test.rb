require "./test/test_helper"
require "wrong/close_to"
require "wrong"

describe "#close_to? (monkey patch for float comparison)" do
  include Wrong

  it "says two equal floats are equal" do
    assert { 5.0.close_to? 5.0 }
  end

  it "says two unequal floats are unequal" do
    deny { 5.0.close_to? 6.0 }
  end

  it "has a default tolerance of 0.001" do
    assert { 5.0.close_to? 5.0001 }
    assert { 5.0.close_to? 5.0009 }
    deny   { 5.0.close_to? 5.001 }
    deny   { 5.0.close_to? 5.01 }
  end

  it "takes a tolerance parameter" do
    assert { 5.0.close_to? 5.01, 0.1 }
  end

  it "excludes the tolerance maximum" do
    assert { 5.0.close_to? 5.9999, 1.0 }
    deny   { 5.0.close_to? 6.00, 1.0 }
  end

  it "works for integers too" do
    assert { 5.close_to? 5 }
    assert { 5.close_to? 5.0001 }
    deny   { 5.close_to? 5.1 }
    assert { 5.close_to? 5.1, 0.5 }
  end

end
