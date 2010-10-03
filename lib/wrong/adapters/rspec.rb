require "wrong"

if Object.const_defined? :Spec
  Spec::Runner.configure do |config|
    include Wrong

    def failure_class
      Spec::Expectations::ExpectationNotMetError
    end
  end
elsif Object.const_defined? :RSpec
  RSpec.configure do |config|
    include Wrong

    def failure_class
      RSpec::Expectations::ExpectationNotMetError
    end
  end
else
  raise "Wrong's RSpec adapter can't find RSpec. Please require 'spec' or 'rspec' first."
end
