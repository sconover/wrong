require "predicated/predicate"
require "predicated/from/ruby_code_string"
require "predicated/to/sentence"

require "wrong/chunk"
require "wrong/config"
require "wrong/failure_message"
require "wrong/rainbow"

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
      raise "Reentry bug while trying to assert(#{args.join(', ')})" if (@_inside_wrong_assert ||= nil)
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

    protected

    # for debugging -- if we couldn't make a predicate out of the code block, then this was why
    def self.last_predicated_error
      @@last_predicated_error ||= nil
    end

    # override (redefine) in adapter if necessary
    def increment_assertion_count
    end

    def aver(valence, explanation = nil, depth = 0, &block)
      increment_assertion_count
      require "wrong/rainbow" if Wrong.config[:color]

      value = block.call
      value = !value if valence == :deny
      if value
        if Wrong.config[:verbose]
          code = Wrong::Chunk.from_block(block, depth + 2).code
          if Wrong.config[:color]
            explanation = explanation.color(:blue) if explanation
            code = code.color(:green)
          end
          message = "#{explanation + ": " if explanation}#{code}"
          puts message
        end
      else
        chunk = Wrong::Chunk.from_block(block, depth + 2)

        message = FailureMessage.new(chunk, valence, explanation).full
        raise failure_class.new(message)
      end
    end
  end

end
