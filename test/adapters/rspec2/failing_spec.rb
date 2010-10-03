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

describe "arithmetic" do
  it "should not work like this" do
    assert { 2 + 2 == 5 }
  end
end

#Spec::Runner.options.parse_format("nested")
#Spec::Runner.options.run_examples
