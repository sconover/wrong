require "./test/test_helper"
require "wrong/close_to"
require "wrong"
require "bigdecimal"
require 'time'

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

  it "also works for bigdecimals" do
    assert { BigDecimal.new("5.0").close_to? 5 }
    assert { BigDecimal.new("5.0").close_to? 5.0001 }
    deny   { BigDecimal.new("5.0").close_to? 5.1 }
  end

  one_hour = 60 * 60
  one_day = one_hour * 24

  it "works for dates" do
    monday = Date.parse("2000-01-02")
    tuesday = Date.parse("2000-01-03")
    assert { monday.close_to? monday }
    deny { monday.close_to? tuesday }
    assert { monday.close_to? tuesday, one_day + 1 }
  end

  it "works for times" do
    noon = Time.parse("12:00:00")
    one_pm = Time.parse("13:00:00")
    one_pm_and_one_second = Time.parse("13:00:01")
    assert { one_pm.close_to? one_pm }
    assert { one_pm.close_to? one_pm_and_one_second, 2 }
    deny { noon.close_to? one_pm }
    assert { noon.close_to? one_pm, one_hour + 1 }
  end

  it "works for datetimes" do
    noon = DateTime.parse("2000-01-01 12:00:00")
    one_pm = DateTime.parse("2000-01-01 13:00:00")
    one_pm_and_one_second = DateTime.parse("2000-01-01 13:00:01")
    assert { one_pm.close_to? one_pm }
    assert { one_pm.close_to? one_pm_and_one_second, 2 }
    deny { noon.close_to? one_pm }
    assert { noon.close_to? one_pm, one_hour + 1 }
  end

end
