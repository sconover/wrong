require "spec"
require "wrong/assert"

Spec::Runner.configure do |config|
  include Wrong::Assert
  
  def failure_class
    Spec::Expectations::ExpectationNotMetError
  end
end
