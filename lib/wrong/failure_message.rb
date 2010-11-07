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

    def basic
      "#{valence == :deny ? "Didn't expect" : "Expected"} #{chunk.code}"
    end
    
    def full
      message = ""
      message << "#{explanation}: " if explanation
      message << basic
      
      formatted_message = if predicate && !(predicate.is_a? Predicated::Conjunction)
        if formatter = FailureMessage.formatter_for(predicate)
          failure = formatter.describe
          failure = failure.bold if Wrong.config[:color]
          failure
        end
      end
      
      unless chunk.details.empty? and formatted_message.nil?
        message << ", but"
      end
      
      message << formatted_message if formatted_message
      message << chunk.details unless chunk.details.empty?
      message
    end

    protected    
    def code
      @code ||= begin
        code = chunk.code
        code = code.color(:blue) if Wrong.config[:color]
        code
      end
    end
    
    def predicate
      @predicate ||= begin
        Predicated::Predicate.from_ruby_code_string(code, block.binding)
      rescue Predicated::Predicate::DontKnowWhatToDoWithThisSexpError, Exception => e
        # save it off for debugging
        @@last_predicated_error = e
        nil
      end
    end
    

  end
end
