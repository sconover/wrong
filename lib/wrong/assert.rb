require "predicated/predicate"
require "predicated/from/callable_object" unless RUBY_VERSION =~ /^1.9/
require "predicated/to/sentence"
require "wrong/chunk"

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
      aver(:assert, &block)
    end

    def deny(&block)
      aver(:deny, &block)
    end

    def catch_raise
      error = nil
      begin
        yield
      rescue Exception, RuntimeError => e
        error = e
      end
      error
    end
    
    overridable do
      def failure_message(method_sym, block, predicate)
        method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
      end
    end
    
    def self.disable_existing_assert_methods(the_class)
      (the_class.public_instance_methods.
        map{|m|m.to_s}.
        select{|m|m =~ /^assert/} - ["assert"]).each do |old_assert_method|
        the_class.class_eval(%{
          def #{old_assert_method}(*args)
            raise "#{old_assert_method} has been disabled.  When you use Wrong, it overrides 'assert', which most test frameworks have defined, and use internally."
          end
        })
      end
    end

    private

    def aver(valence, &block)
      value = block.call
      value = !value if valence == :deny
      unless value
        predicate = begin
          Predicated::Predicate.from_callable_object(block)
        rescue => e
          raise e if RUBY_VERSION < "1.9"
          code = Wrong::Chunk.from_block(block).code
          Predicated::Predicate.from_ruby_code_string(code, block.binding)
        end
        message = failure_message(valence, block, predicate)
        raise failure_class.new(message)
      end
    end

  end
end
