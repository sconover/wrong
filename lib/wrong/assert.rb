require "predicated/predicate"
require "predicated/from/callable_object"
require "predicated/to/sentence"

module Wrong
  module Assert
    def assert(&block)
      raise FailureMessageForBlock.new(block).failure_str unless block.call
    end

    def deny(&block)
      raise FailureMessageForBlock.new(block).reverse_failure_str if block.call
    end
    
    class FailureMessageForBlock
      include Predicated
      
      def initialize(block)
        @block = block
      end

      def failure_str
        convert_to_predicate.to_negative_sentence
      end

      def reverse_failure_str
        convert_to_predicate.to_sentence
      end
      
      private
      def convert_to_predicate
        Predicate.from_callable_object(@block)
      end
    end
  end
end