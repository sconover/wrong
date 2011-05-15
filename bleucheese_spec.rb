class BleuCheese
  def smell
    8999
  end
end

require 'rspec'
require "wrong"
require "wrong/adapters/rspec"

# David's solution
# require "rspec/expectations"
# require "wrong"
# require "wrong/adapters/rspec"
# RSpec.configuration.expect_with :stdlib

# Alex's solution
module RSpec::Matchers
  remove_method(:expect)
end

Wrong.config.alias_assert :expect

# This test should fail, yet it passes, since RSpec aliases expect to lambda
describe BleuCheese do
  it "stinks with expect" do
    expect { BleuCheese.new.smell > 9000 }
  end
end
