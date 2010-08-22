require "predicated/predicate"
require "predicated/from/callable_object"
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

    class AssertionFailedError < RuntimeError;
    end

    def failure_class
      AssertionFailedError
    end

    def assert(explanation = nil, depth = 0, &block)
      aver(:assert, explanation, depth, &block)
    end

    def deny(explanation = nil, depth = 0, &block)
      aver(:deny, explanation, depth, &block)
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
        map { |m| m.to_s }.
        select { |m| m =~ /^assert/ } - ["assert"]).each do |old_assert_method|
        the_class.class_eval(%{
          def #{old_assert_method}(*args)
            raise "#{old_assert_method} has been disabled.  When you use Wrong, it overrides 'assert', which most test frameworks have defined, and use internally."
          end
        })
      end
    end

    private

    def aver(valence, explanation = nil, depth = 0, &block)
      value = block.call
      value = !value if valence == :deny
      unless value
        chunk = Wrong::Chunk.from_block(block, depth + 2)
        code = chunk.code
        predicate = begin
          Predicated::Predicate.from_ruby_code_string(code, block.binding)
        rescue Predicated::Predicate::DontKnowWhatToDoWithThisSexpError
          nil
        rescue Exception
          nil
        end
        message = ""
        message << "#{explanation}: " if explanation
        message << "#{valence == :deny ? "Didn't expect" : "Expected"} #{code}, but"
        message << " #{failure_message(valence, block, predicate)}" if predicate
        message << chunk.details
        raise failure_class.new(message)
      end
    end
  end

end
