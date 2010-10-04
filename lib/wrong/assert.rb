require "predicated/predicate"
require "predicated/from/ruby_code_string"
require "predicated/to/sentence"

require "wrong/chunk"
require "wrong/config"
require "wrong/failure_message"
require "wrong/ruby2ruby_patch" # need to patch it after some other stuff loads

module Wrong
  module Assert

    class AssertionFailedError < RuntimeError
    end

    def failure_class
      AssertionFailedError
    end

    # Actual signature: assert(explanation = nil, depth = 0, &block)
    def assert(*args, &block)
      # to notice (and fail fast from) odd recursion problem
      raise "Reentry bug while trying to assert(#{args.join(', ')})" if @_inside_wrong_assert
      @_inside_wrong_assert = true

      if block.nil?
        begin
          super(*args) # if there's a framework assert method (sans block), then call it
        rescue NoMethodError => e
          # note: we're not raising an AssertionFailedError because this is a programmer error, not a failed assertion
          raise "You must pass a block to Wrong's assert and deny methods"
        end
      else
        aver(:assert, *args, &block)
      end
    ensure
      @_inside_wrong_assert = false
    end

    # Actual signature: deny(explanation = nil, depth = 0, &block)
    def deny(*args, &block)
      if block.nil?
        test = args.first
        msg = args[1]
        assert !test, msg  # this makes it get passed up to the framework
      else
        aver(:deny, *args, &block)
      end
    end

    def summary(method_sym, predicate)
      method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
    end

    protected

    # for debugging -- if we couldn't make a predicate out of the code block, then this was why
    def self.last_predicated_error
      @@last_predicated_error ||= nil
    end

    # todo: move some/all of this into FailureMessage
    def full_message(chunk, block, valence, explanation)
      code = chunk.code

      predicate = begin
        Predicated::Predicate.from_ruby_code_string(code, block.binding)
      rescue Predicated::Predicate::DontKnowWhatToDoWithThisSexpError, Exception => e
        # save it off for debugging
        @@last_predicated_error = e
        nil
      end

      code = code.color(:blue) if Wrong.config[:color]
      message = ""
      message << "#{explanation}: " if explanation
      message << "#{valence == :deny ? "Didn't expect" : "Expected"} #{code}, but "
      if predicate && !(predicate.is_a? Predicated::Conjunction)
        message << summary(valence, predicate)
        if formatter = FailureMessage.formatter_for(predicate)
          failure = formatter.describe
          failure = failure.bold if Wrong.config[:color]
          message << failure
        end
      end
      message << chunk.details
      message
    end

    def aver(valence, explanation = nil, depth = 0, &block)
      require "wrong/rainbow" if Wrong.config[:color]

      value = block.call
      value = !value if valence == :deny
      unless value

        chunk = Wrong::Chunk.from_block(block, depth + 2)

        message = full_message(chunk, block, valence, explanation)
        raise failure_class.new(message)
      end
    end
  end

end
