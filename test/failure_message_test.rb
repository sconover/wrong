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

  end
end
