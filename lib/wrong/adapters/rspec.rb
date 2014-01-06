require "wrong"
require "wrong/terminal"

if Object.const_defined? :RSpec
  # RSpec 2

  if RSpec.const_defined? :Rails
    require 'rails/version'
    case Rails::VERSION::STRING
    when /^4\.1/
      # RSpec 2 plus Rails 4.1
      module RSpec::Rails::MinitestAssertionAdapter::ClassMethods
        def define_assertion_delegators_with_removed
          define_assertion_delegators_without_removed
          class_eval do
            remove_method :assert
          end
        end
        alias_method_chain :define_assertion_delegators, :removed
      end

    when /^4\.0/, /^3\./
      # RSpec 2 plus Rails 3
      module RSpec::Rails::TestUnitAssertionAdapter
        included do
          define_assertion_delegators
          class_eval do
            remove_method :assert
          end
        end
      end
    else
      raise "Wrong's RSpec adapter can't be applied to your Rails version #{Rails::VERSION::STRING}"
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

 # Disallow alias_assert :expect
 module Wrong
   class Config
     alias :alias_assert_or_deny_original :alias_assert_or_deny
     def alias_assert_or_deny(valence, extra_name, options = {})
       if extra_name.to_sym == :expect
         if options[:override]
           RSpec::Matchers.class_eval do
             remove_method(:expect)
           end
         else
           raise ConfigError.new("RSpec already has a method named #{extra_name}. Use alias_#{valence} :#{extra_name}, :override => true if you really want to do this.")
         end
       end
       alias_assert_or_deny_original(valence, extra_name, options)
     end
   end
 end

  # tweak terminal width so exceptions wrap properly inside RSpec output
  Wrong::Terminal.width -= 7

elsif Object.const_defined? :Spec
  # RSpec 1
 Spec::Runner.configure do |config|
   include Wrong

   def failure_class
     Spec::Expectations::ExpectationNotMetError
   end
 end

 # Disallow alias_assert :expect
 module Wrong
   class Config
     alias :alias_assert_or_deny_original :alias_assert_or_deny
     def alias_assert_or_deny(valence, extra_name, options = {})
       if extra_name.to_sym == :expect
         if options[:override]
           Spec::Example::ExampleMethods.class_eval do
             remove_method(:expect)
           end
         else
           raise ConfigError.new("RSpec already has a method named #{extra_name}. Use alias_#{valence} :#{extra_name}, :override => true if you really want to do this.")
         end
       end
       alias_assert_or_deny_original(valence, extra_name, options)
     end
   end
 end


else
 raise "Wrong's RSpec adapter can't find RSpec. Please require 'spec' or 'rspec' before requiring 'wrong/adapters/rspec'."
end
