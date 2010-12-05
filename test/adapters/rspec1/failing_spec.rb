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

describe "arithmetic" do
  it "should not work like this" do
    assert { 2 + 2 == 5 }
  end
end

Spec::Runner.options.parse_format("nested")
Spec::Runner.options.run_examples
