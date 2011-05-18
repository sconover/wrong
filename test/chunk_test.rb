here = File.expand_path(File.dirname(__FILE__))
require "#{here}/test_helper"
require "wrong/chunk"
require 'yaml'

unless Object.const_defined?(:Chunk)
  Chunk = Wrong::Chunk
end

describe Chunk do
  describe "#from_block" do
    it "reads the source location" do
      file, line = __FILE__, __LINE__
      chunk = Chunk.from_block(proc { "hi" })
      assert(chunk.file == file)
      assert(chunk.line_number == line+1)
    end
  end

  describe "line numbers" do
    before do
      @chunk = Wrong::Chunk.new("foo.rb", 10)
    end
    it "#line_index is zero-based" do
      assert(@chunk.line_index == 9)
    end
    it "#location is one-based" do
      assert(@chunk.location == "foo.rb:10")
    end
  end

  describe "parsing" do
    it "reads a statement on a line by itself" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi"
      CODE
      code = chunk.sexp.to_ruby
      assert(code == '"hi"')
    end

    it "reads a statement on multiple lines" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        proc do
          "hi"
        end
      CODE
      code = chunk.sexp.to_ruby
      assert(code == "proc { \"hi\" }")
    end

    it "fails if there's a stray close-paren symbol on the last line (sorry)" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi" )
      CODE
      assert(chunk.sexp.nil?)
    end

    it "fails if there's a stray close-block symbol on the last line (sorry)" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi" }
      CODE
      assert(chunk.sexp.nil?)
    end

    it "fails if it can't parse the code" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        }
      CODE
      assert(chunk.sexp.nil?)
    end

    it "fails if it can't find the file" do
      chunk = Chunk.new("nonexistent_file.rb", 0)
      error = get_error { chunk.sexp }
      assert error.is_a? Errno::ENOENT
    end

    it "finds the file to parse even when inside a chdir to a child directory" do
      Dir.chdir("#{here}") do
        chunk = Chunk.new __FILE__, __LINE__ + 1; <<-CODE
        "hi"
        CODE
        code = chunk.sexp.to_ruby
        assert(code == '"hi"')
      end
    end
  end

  describe "#claim" do
    it "returns the part of the assertion statement inside the curly braces" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { x == 5 }
      CODE
      full_code = chunk.sexp.to_ruby
      assert(full_code == "assert { (x == 5) }")
      claim_code = chunk.claim.to_ruby
      assert claim_code == "(x == 5)"
    end


    it "reads an assert statement on a line by itself" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { x == 5 }
      CODE
      claim_code = chunk.claim.to_ruby
      assert claim_code == "(x == 5)"
    end

    it "reads an assert statement on multiple lines" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert do
           x == 5
        end
      CODE
      claim_code = chunk.claim.to_ruby
      assert claim_code == "(x == 5)"
    end

    def yielding
      yield
    end

    if RUBY_VERSION > "1.9"
      it "reads an assert statement that's nested inside another yield block on the same line (Ruby 1.9 only)" do
        chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
          yielding { assert { x == 5 }}
        CODE
        code = chunk.claim.to_ruby
        assert code == "(x == 5)"
      end

#      test "goes crazy if you try to nest two asserts on the same line"
    end

    it "if it can't find an assertion, it uses the whole chunk" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        yielding { x == 5 }
      CODE
      code = chunk.claim.to_ruby
      assert code == "yielding { (x == 5) }"
    end

    it "fails if it can't parse the code" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        }
      CODE
      error = get_error {
        chunk.claim
      }
      assert error.message.include?("Could not parse")
    end
  end

  describe "#parts" do
    it "returns all unique sub-expressions of the main sexpression" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { (x == 5) && (y == (z + 10)) }
      CODE
      code_parts = chunk.parts
      assert code_parts == <<-PARTS.split("\n")
((x == 5) and (y == (z + 10)))
(x == 5)
x
5
(y == (z + 10))
y
(z + 10)
z
10
      PARTS
    end

    it "omits the method-call-sans-block part of a method call with a block" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { rescuing { 1 + 2 } }
      CODE
      code_parts = chunk.parts
      assert !code_parts.include?("rescuing")
    end
    
    it "skips assignments" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        x = 7; x
      CODE
      assert !chunk.parts.include?("(x = 7)")
    end    
  end

  describe "#details" do
    def details(&block)
      chunk = Chunk.from_block(block, 1)
      d = chunk.details
#      puts d
      d
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
      assert d.include? "exception_with_newlines is #<Exception: --- \n      :flavor: vanilla>"
    end

    it "skips assignments" do
      y = 14
      d = details { x = 7; y }
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

      it 'inspects its value' do
        assert @chunk.pretty_value(12) == "12"
        assert @chunk.pretty_value("foo") == "\"foo\""
      end
      
      it 'escapes newlines in strings' do
        assert @chunk.pretty_value("foo\nbar\nbaz") == "\"foo\\nbar\\nbaz\""
      end
      
      it 'indents newlines in raw inspect values (e.g. exceptions or YAML or whatever)' do
        w = Weirdo.new("foo\nbar\nbaz")
        assert @chunk.pretty_value(w) == "foo\n      bar\n      baz"
      end
      
      # def pretty_value(value, starting_col = 0, indent_wrapped_lines = 3, size = Chunk.terminal_size)
      
      it 'inserts newlines in really long values, wrapped at the terminal width' do
        abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
        pretty = @chunk.pretty_value(abc, 0, 0, 10)
        assert pretty == <<-DONE.chomp
abcdefghij
klmnopqrst
uvwxyz
DONE
      end
      
      it 'subtracts the starting column from the wrapped width of the first line' do
        abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
        pretty = @chunk.pretty_value(abc, 2, 0, 10)
        assert pretty == <<-DONE.chomp
abcdefgh
ijklmnopqr
stuvwxyz
        DONE
      end
      
      it "indents wrapped lines" do
        abc = Weirdo.new("abcdefghijklmnopqrstuvwxyz")
        pretty = @chunk.pretty_value(abc, 2, 3, 10)
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
        pretty = @chunk.pretty_value(object, 2, 3, 80)
        assert pretty == <<-DONE.chomp
--- 
      :flavor: vanilla
        DONE
      end

    end

  end
end
