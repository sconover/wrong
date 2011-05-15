class BleuCheese
  def smell
    8999
  end
end

require 'rspec'
require "wrong"
require "wrong/adapters/rspec"

Wrong.config.alias_assert :should

describe BleuCheese do
  it "stinks" do
    should { BleuCheese.new.smell > 9000 }
  end
end


# This test should fail, yet it passes, since RSpec aliases expect to lambda
Wrong.config.alias_assert :expect

describe BleuCheese do
  it "stinks with expect" do
    expect { BleuCheese.new.smell > 9000 }
  end
end
