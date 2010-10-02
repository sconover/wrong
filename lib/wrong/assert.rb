require "predicated/predicate"
require "predicated/from/ruby_code_string"
require "predicated/to/sentence"

require "wrong/chunk"
require "wrong/config"
require "wrong/ruby2ruby_patch" # need to patch it after some other stuff loads

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

    # Actual signature: assert(explanation = nil, depth = 0, block)
    def assert(*args, &block)
      if block.nil?
        begin
          super
        rescue NoMethodError => e
          # note: we're not raising an AssertionFailedError because this is a programmer error, not a failed assertion
          raise "You must pass a block to Wrong's assert and deny methods"
        end
      else
        aver(:assert, *args, &block)
      end
    end

    # Actual signature: deny(explanation = nil, depth = 0, block)    
    def deny(*args, &block)
      if block.nil?
        test = args.first
        msg = args[1]
        assert !test, msg  # this makes it get passed up to the framework
      else
        aver(:deny, *args, &block)
      end
    end

    overridable do
      def failure_message(method_sym, block, predicate)
        method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
      end
    end

    protected

    # for debugging -- if we couldn't make a predicate out of the code block, then this was why
    def self.last_predicated_error
      @@last_predicated_error ||= nil
    end

    def aver(valence, explanation = nil, depth = 0, &block)
      require "wrong/rainbow" if Wrong.config[:color]
      
      value = block.call
      value = !value if valence == :deny
      unless value
        chunk = Wrong::Chunk.from_block(block, depth + 2)
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
          failure = failure_message(valence, block, predicate)
          failure = failure.bold if Wrong.config[:color] 
          message << failure
        end
        message << chunk.details
        raise failure_class.new(message)
      end
    end
  end

end
