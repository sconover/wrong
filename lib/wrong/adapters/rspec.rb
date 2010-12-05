require "wrong"

if Object.const_defined? :RSpec
  # RSpec 2

 if RSpec.const_defined? :Rails
  # RSpec 2 plus Rails 3
   module RSpec::Rails::TestUnitAssertionAdapter
     included do
       define_assertion_delegators
       class_eval do
         remove_method :assert
       end
     end
   end
 end

 # This would work if we didn't need to define failure_class
 # todo: figure out how to get RSpec's config object to class_eval or whatever
 # Rspec.configure do |config|
 #   config.include Wrong
 #   def failure_class
 #     RSpec::Expectations::ExpectationNotMetError
 #   end
 # end

 module RSpec
   module Core
     class ExampleGroup
       include Wrong
 
       def failure_class
         RSpec::Expectations::ExpectationNotMetError
       end
     end
   end
 end

elsif Object.const_defined? :Spec
  # RSpec 1
 Spec::Runner.configure do |config|
   include Wrong

   def failure_class
     Spec::Expectations::ExpectationNotMetError
   end
 end

else
 raise "Wrong's RSpec adapter can't find RSpec. Please require 'spec' or 'rspec' before requiring 'wrong/adapters/rspec'."
end
