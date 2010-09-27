require "spec"
require "wrong"

Spec::Runner.configure do |config|
  include Wrong
  
  def failure_class
    Spec::Expectations::ExpectationNotMetError
  end
end
