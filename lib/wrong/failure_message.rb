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
  end
end
