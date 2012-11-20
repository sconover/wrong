require "./test/test_helper"
require "wrong/assert"
require "wrong/chunk"
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

# normalize yaml
def y(s)
  s.gsub(/--- $/, "---").chomp
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
      assert { Wrong::FailureMessage.formatters.include?(::BogusFormatter) }
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
        assert { message.details.empty? }
        deny { message.full.include? ", but" }
      end

      it "says 'but' if there are details" do
        @chunk = Wrong::Chunk.new(__FILE__, __LINE__ + 1) do
          2 + 2 == 5
        end
        assert { message.full.include? ", but\n    (2 + 2) is 4" }
      end
    end

    describe "#details" do
      def details(&block)
        @chunk = Wrong::Chunk.from_block(block, 1)
        message.details
      end

      it "returns an empty string if there are no parts" do
        d = details { assert { true } }
        assert d == ""
      end

      it "returns an string beginning with a newline if there are parts" do
        x = 10
        d = details { assert { x == 10 } }
        assert d == "\n    x is 10\n"
      end

      it "skips literals" do
        d = details { assert { 10 == 11 } }
        assert d == ""
      end

      it "shows lots of details" do
        x = 10
        d = details { assert { (x * (x - 10)) == (x / (x + 10)) } }
        assert d == <<-DETAILS

    (x * (x - 10)) is 0
    x is 10
    (x - 10) is 0
    (x / (x + 10)) is 0
    (x + 10) is 20
        DETAILS
      end

      it "skips duplicates" do
        x = 10
        d = details { assert { (x + 5) == 1 + (x + 5) } }
        assert d == <<-DETAILS

    (x + 5) is 15
    x is 10
    (1 + (x + 5)) is 16
        DETAILS
      end

      it "shows exceptions" do
        d = details { assert { (raise "hi") == 1 } }
        assert d == "\n    raise(\"hi\") raises RuntimeError: hi\n"
      end

      it "indents newlines inside the exception message" do
        d = details { assert { (raise "hello\nsailor") == 1 } }
        assert d == "\n    raise(\"hello\\nsailor\") raises RuntimeError: hello\n      sailor\n"
      end

      it "abridges exceptions with no message" do
        d = details { assert { (raise Exception.new) == 1 } }
        assert d == "\n    raise(Exception.new) raises Exception\n" +
            "    Exception.new is #<Exception: Exception>\n"
      end

      it "inspects values" do
        x = "flavor:\tvanilla"
        d = details { assert { x == "flavor:\tchocolate" } }
        # this means it's a literal slash plus t inside double quotes -- i.e. it shows the escaped (inspected) string
        assert d == "\n" + '    x is "flavor:\tvanilla"' + "\n"
      end

      it "splits lower-down details correctly (bug)" do
        hash = {:flavor => "vanilla"}
        exception_with_newlines = Exception.new(hash.to_yaml.chomp)
        d = details {
          rescuing { raise exception_with_newlines }.message.include?(":flavor: chocolate")
        }
        assert (y(d).include? "exception_with_newlines is #<Exception: ---\n      :flavor: vanilla>"), d.inspect
      end

      it "skips assignments" do
        y = 14
        d = details do
          x = 7; y
        end
        assert d !~ /x = 7/
        assert d =~ /y is 14/
      end

      class Weirdo
        def initialize(inspected_value)
          @inspected_value = inspected_value
        end

        def inspect
          @inspected_value
        end
      end

      it "indents unescaped newlines inside the inspected value" do
        x = Weirdo.new("first\nsecond\nthird")
        d = details { assert { x == "foo" } }
        assert d == "\n    x is first\n      second\n      third\n"
      end

      describe '#pretty_value' do
        before do
          @chunk = chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
          true
          CODE
        end

        after do
          Wrong::Terminal.width = 80
        end

        it 'inspects its value' do
          assert message.pretty_value(12) == "12"
          assert message.pretty_value("foo") == "\"foo\""
        end

        it 'escapes newlines in strings' do
          assert message.pretty_value("foo\nbar\nbaz") == "\"foo\\nbar\\nbaz\""
        end

        it 'indents newlines in raw inspect values (e.g. exceptions or YAML or whatever)' do
          w = Weirdo.new("foo\nbar\nbaz")
          assert message.pretty_value(w) == "foo\n      bar\n      baz"
        end

        it "returns the terminal width" do
          assert Terminal.width.is_a? Fixnum
          assert Terminal.width > 0
        end

        it "can fake the terminal width" do
          Terminal.width = 66
          assert Terminal.width == 66
        end

        # def pretty_value(value, starting_col = 0, indent_wrapped_lines = 3, size = Terminal.size)

        it 'inserts newlines in really long values, wrapped at the given width' do
          abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
          pretty = message.pretty_value(abc, 0, 0, 10)
          assert pretty == <<-DONE.chomp
abcdefghij
klmnopqrst
uvwxyz
          DONE
        end

        it 'inserts newlines in really long values, wrapped at the terminal width' do
          Terminal.width = 10
          abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
          pretty = message.pretty_value(abc, 0, 0)
          assert pretty == <<-DONE.chomp
abcdefghij
klmnopqrst
uvwxyz
          DONE
        end

        it 'subtracts the starting column from the wrapped width of the first line' do
          abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
          pretty = message.pretty_value(abc, 2, 0, 10)
          assert pretty == <<-DONE.chomp
abcdefgh
ijklmnopqr
stuvwxyz
          DONE
        end

        it "indents wrapped lines" do
          abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
          pretty = message.pretty_value(abc, 2, 3, 10)
          assert pretty == <<-DONE.chomp
abcdefgh
   ijklmno
   pqrstuv
   wxyz
          DONE
        end

        it "wraps correctly" do
          hash = {:flavor => "vanilla"}
          object = Weirdo.new(hash.to_yaml.chomp)
          pretty = message.pretty_value(object, 2, 3, 80)
          assert y(pretty) == y(<<-DONE), pretty.inspect
---
      :flavor: vanilla
          DONE
        end


      end
    end
  end
end
