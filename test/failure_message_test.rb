require "./test/test_helper"
require "wrong/assert"
require "wrong/failure_message"

module Wrong

  class BogusFormatter < FailureMessage::Formatter
    def match?
      predicate.is_a? BogusPredicate
    end

    def describe
      "bogus #{predicate.object_id}"
    end
  end

  class BogusPredicate < Predicated::Predicate
  end

  describe FailureMessage::Formatter do
    include Wrong::Assert

    it "describes a predicate" do
      predicate = BogusPredicate.new
      formatter = BogusFormatter.new(predicate)
      assert { formatter.describe == "bogus #{predicate.object_id}" }
    end
  end

  describe FailureMessage do
    include Wrong::Assert

    it "can register a formatter class for a predicate pattern" do
      FailureMessage.register_formatter(BogusFormatter)
      assert { FailureMessage.formatter_for(BogusPredicate.new).is_a? BogusFormatter }
      assert { FailureMessage.formatters.include?(BogusFormatter)}
    end

    def message(options = {})
      block = options[:block] || proc { 2 + 2 == 5 }
      chunk = Chunk.from_block(block)
      valence = options[:valence] || :assert 
      explanation = options[:explanation]
      FailureMessage.new(chunk, block, valence, explanation)
    end

    describe "#basic" do      
      it "shows the code" do
        assert { message.basic == "Expected ((2 + 2) == 5)" }
      end
      
      it "reverses the message for :deny valence" do
        assert { message(:valence => :deny).basic == "Didn't expect ((2 + 2) == 5)" }
      end
    end
    
    describe '#full' do
      it "contains the basic message" do
        assert { message.full.include? message.basic }
      end

      it "contains the explanation if there is one" do
        msg = message(:explanation => "the sky is falling")
        assert { msg.full.include? "the sky is falling" }
      end
      
      it "doesn't say 'but' if there are no details" do
        block = proc { 7 }
        chunk = Chunk.from_block(block)
        assert { chunk.details.empty? }
        msg = message(:block => block)
        deny { msg.full.include? ", but"}
      end
      
      it "say 'but' with if there are details" do
        block = proc { 2 + 2 == 5 }
        chunk = Chunk.from_block(block)
        msg = message(:block => block)
        assert { msg.full.include? ", but\n    (2 + 2) is 4"}
      end
      
    end

  end
end
