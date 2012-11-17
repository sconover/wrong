here = File.expand_path(File.dirname(__FILE__))
require "#{here}/test_helper"
require "wrong/chunk"
require 'yaml'
require 'wrong/helpers'

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
      assert code_parts == <<-PARTS.split("\n"), code_parts
(x == 5) and (y == (z + 10))
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

end
