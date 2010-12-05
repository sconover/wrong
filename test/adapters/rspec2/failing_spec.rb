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

describe "wrong's failure" do
  it "is an RSpec exception" do
    e = rescuing {
      assert { false }
    }
    e.should be_a(RSpec::Expectations::ExpectationNotMetError)
  end
end

describe "arithmetic" do
  it "should not work like this" do
    assert { 2 + 2 == 5 }
  end
end

# now, thanks to the require 'rspec/autorun', this spec will run and fail
