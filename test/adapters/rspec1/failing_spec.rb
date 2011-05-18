# This is a failing spec for testing RSpec 1.3 integration

require "rubygems"
require "bundler"
Bundler.setup

require "spec"

here = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{here}/../../../lib"
require "wrong/adapters/rspec"

# since we're not running 'spec' we have to do some stuff ourselves
include Spec::DSL::Main

describe "wrong's failure" do
  it "is an RSpec exception" do
    e = rescuing {
      assert { false }
    }
    e.should be_a(Spec::Expectations::ExpectationNotMetError)
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
      e.should be_a(Spec::Expectations::ExpectationNotMetError)
    end
  end
end


describe "arithmetic" do
  it "should not work like this" do
    assert { 2 + 2 == 5 }
  end
end

Spec::Runner.options.parse_format("nested")
Spec::Runner.options.run_examples
