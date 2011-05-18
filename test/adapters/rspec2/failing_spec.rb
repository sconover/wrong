# This is a failing spec for testing RSpec 2 integration

require "rubygems"
require "bundler"
Bundler.setup

require "rspec"

here = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{here}/../../../lib"

# since we're not running 'rspec' we have to do some stuff ourselves
require 'rspec'
require 'rspec/core'
puts RSpec::Core::Version::STRING

require 'rspec/autorun'
require "wrong/adapters/rspec"

# these first ones should pass, since they describe how Wrong works inside the RSpec ecosystem
describe "wrong's failure" do
  it "is an RSpec exception" do
    e = rescuing {
      assert { false }
    }
    e.should be_a(RSpec::Expectations::ExpectationNotMetError)
  end
end

describe "alias_assert" do
  it "works for an innocuous name" do
    e = rescuing {
      Wrong.config.alias_assert :allow
    }
    e.should be_nil
  end

  describe ":expect" do
    it "fails if RSpec is active" do
      e = rescuing {
        Wrong.config.alias_assert :expect
      }
      e.should be_a(Wrong::Config::ConfigError)
    end

    it "works if we pass :override => true" do
      e = rescuing {
        Wrong.config.alias_assert :expect, :override => true
      }
      e.should be_nil

      e = rescuing {
        expect { false }
      }
      e.should_not be_nil
      e.should be_a(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end

describe "arithmetic" do
  it "should not work like this" do
    assert { 2 + 2 == 5 }
  end
end

# now, thanks to the require 'rspec/autorun', this spec will run and fail
