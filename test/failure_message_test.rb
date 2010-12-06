require "./test/test_helper"
require "wrong/assert"
require "wrong/failure_message"

class BogusFormatter < Wrong::FailureMessage::Formatter
  def match?
    predicate.is_a? BogusPredicate
  end

  def describe
    "bogus #{predicate.object_id}"
  end
end

class BogusPredicate < Predicated::Predicate
end

module Wrong

  describe Wrong::FailureMessage::Formatter do
    include Wrong::Assert

    it "describes a predicate" do
      predicate = BogusPredicate.new
      formatter = BogusFormatter.new(predicate)
      assert { formatter.describe == "bogus #{predicate.object_id}" }
    end
  end

  describe Wrong::FailureMessage do    
    include Wrong::Assert

    it "can register a formatter class for a predicate pattern" do
      Wrong::FailureMessage.register_formatter(::BogusFormatter)
      assert { Wrong::FailureMessage.formatter_for(::BogusPredicate.new).is_a? ::BogusFormatter }
      assert { Wrong::FailureMessage.formatters.include?(::BogusFormatter)}
    end

    before do
      @chunk = Wrong::Chunk.new(__FILE__, __LINE__ + 1) do
        2 + 2 == 5
      end
    end

    def message(options = {}, &block)
      valence = options[:valence] || :assert 
      explanation = options[:explanation]
      Wrong::FailureMessage.new(@chunk, valence, explanation)
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
        @chunk = Wrong::Chunk.new(__FILE__, __LINE__ + 1) do
          2
        end
        assert { @chunk.details.empty? }
        deny { message.full.include? ", but"}
      end
      
      it "says 'but' if there are details" do
        @chunk = Wrong::Chunk.new(__FILE__, __LINE__ + 1) do
          2 + 2 == 5
        end
        assert { message.full.include? ", but\n    (2 + 2) is 4"}
      end
            
    end

  end
end
