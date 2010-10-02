require "spec"
require "wrong"

if Object.const_defined? :Spec
Spec::Runner.configure do |config|
  include Wrong
  
  def failure_class
    Spec::Expectations::ExpectationNotMetError
  end
end
else
  Spec::Runner.configure do |config|
    include Wrong

    def failure_class
      Spec::Expectations::ExpectationNotMetError
    end
  end
end
