require "predicated/predicate"
require "predicated/from/callable_object"
require "predicated/to/sentence"

#see http://yehudakatz.com/2009/01/18/other-ways-to-wrap-a-method/
class Module
  def overridable(&blk)
    mod = Module.new(&blk)
    include mod
  end
end

module Wrong
  module Assert
    
    class AssertionFailedError < RuntimeError; end
    
    def failure_class
      AssertionFailedError
    end
    
    def assert(&block)
      unless block.call
        raise failure_class.new(
          failure_message(:assert, block, Predicated::Predicate.from_callable_object(block))
        )
      end
    end


    def deny(&block)
      if block.call
        raise failure_class.new(
          failure_message(:deny, block, Predicated::Predicate.from_callable_object(block))
        )
      end
    end

    def catch_raise
      error = nil
      begin
        yield
      rescue Exception, RuntimeError => e
        error = e
      end
      e
    end
    
    overridable do
      def failure_message(method_sym, block, predicate)
        method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
      end
    end
    
    def self.disable_existing_assert_methods(the_class)
      (the_class.public_instance_methods.
        select{|m|m =~ /^assert/} - ["assert"]).each do |old_assert_method|
        the_class.class_eval(%{
          def #{old_assert_method}(*args)
            raise "#{old_assert_method} has been disabled.  When you use Wrong, it overrides 'assert', which most test frameworks have defined, and use internally."
          end
        })
      end
    end  
    
  end
end