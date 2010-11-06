module Wrong
  class FailureMessage
    @@formatters = []

    def self.register_formatter(formatter)
      @@formatters << formatter
    end

    def self.formatters
      @@formatters
    end

    def self.formatter_for(predicate)
      @@formatters.each do |formatter_class|
        formatter = formatter_class.new(predicate)
        if formatter.match?
          return formatter
        end
      end
      nil
    end

    class Formatter
      def self.register
        Wrong::FailureMessage.register_formatter(self)
      end

      attr_reader :predicate

      def initialize(predicate)
        @predicate = predicate
      end

      def describe(valence)

      end

      def match?
        false
      end
    end
    
    
    attr_accessor :chunk, :block, :valence, :explanation
    
    def initialize(chunk, block, valence, explanation)
      @chunk, @block, @valence, @explanation = chunk, block, valence, explanation
    end
    
    def summary(method_sym, predicate)
      method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
    end

    def full
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
    
  end
end
