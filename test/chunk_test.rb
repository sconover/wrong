require "./test/test_helper"
require "wrong/chunk"

unless Object.const_defined?(:Chunk)
  Chunk = Wrong::Chunk
end

regarding Chunk do
  regarding "#from_block" do
    test "reads the source location" do
      file, line = __FILE__, __LINE__
      chunk = Chunk.from_block(proc { "hi" })
      assert(chunk.file == file)
      assert(chunk.line_number == line+1)
    end
  end

  regarding "line numbers" do
    before do
      @chunk = Wrong::Chunk.new("foo.rb", 10)
    end
    test "#line_index is zero-based" do
      assert(@chunk.line_index == 9)
    end
    test "#location is one-based" do
      assert(@chunk.location == "foo.rb:10")
    end
  end

  regarding "#parse" do
    test "reads a statement on a line by itself" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi"
      CODE
      code = chunk.parse.to_ruby
      assert(code == '"hi"')
    end

    test "reads a statement on multiple lines" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        proc do
          "hi"
        end
      CODE
      code = chunk.parse.to_ruby
      assert(code == "proc { \"hi\" }")
    end

    test "fails if there's a stray close-paren symbol on the last line (sorry)" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi" )
      CODE
      assert(chunk.parse.nil?)
    end

    test "fails if there's a stray close-block symbol on the last line (sorry)" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        "hi" }
      CODE
      assert(chunk.parse.nil?)
    end

    test "fails if it can't parse the code" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        }
      CODE
      assert(chunk.parse.nil?)
    end

    test "fails if it can't find the file" do
      chunk = Chunk.new("nonexistent_file.rb", 0)
      error = get_error { chunk.parse }
      assert error.is_a? Errno::ENOENT
    end

  end

  regarding "#claim" do
    test "returns the part of the assertion statement inside the curly braces" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { x == 5 }
      CODE
      full_code = chunk.parse.to_ruby
      assert(full_code == "assert { (x == 5) }")
      claim_code = chunk.claim.to_ruby
      assert claim_code == "(x == 5)"
    end


    test "reads an assert statement on a line by itself" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        assert { x == 5 }
      CODE
      claim_code = chunk.claim.to_ruby
      assert claim_code == "(x == 5)"
    end

    test "reads an assert statement on multiple lines" do
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
      test "reads an assert statement that's nested inside another yield block on the same line (Ruby 1.9 only)" do
        chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
          yielding { assert { x == 5 }}
        CODE
        code = chunk.claim.to_ruby
        assert code == "(x == 5)"
      end

#      test "goes crazy if you try to nest two asserts on the same line"
    end

    test "if it can't find an assertion, it uses the whole chunk" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        yielding { x == 5 }
      CODE
      code = chunk.claim.to_ruby
      assert code == "yielding { (x == 5) }"
    end

    test "fails if it can't parse the code" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        }
      CODE
      error = get_error {
        chunk.claim
      }
      assert error.message.include?("Could not parse")
    end
  end

  regarding "#parts" do
    test "returns all unique sub-expressions of the main sexpression" do
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
  end

  regarding "#details" do
    def details(&block)
      chunk = Chunk.from_block(block, 1)
      d = chunk.details
#      puts d
      d
    end

    test "returns an empty string if there are no parts" do
      d = details { assert { true } }
      assert d == ""
    end

    test "returns an string beginning with a newline if there are parts" do
      x = 10
      d = details { assert { x == 10 } }
      assert d == "\n    x is 10\n"
    end

    test "skips literals" do
      d = details { assert { 10 == 11 } }
      assert d == ""
    end

    test "shows lots of details" do
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

    test "skips duplicates" do
      x = 10
      d = details { assert { (x + 5) == 1 + (x + 5) } }
      assert d == <<-DETAILS

    (x + 5) is 15
    x is 10
    (1 + (x + 5)) is 16
      DETAILS
    end

    test "shows exceptions" do
      d = details { assert { (raise "hi") == 1} }
      assert d == "\n    raise(\"hi\") raises RuntimeError: hi\n"
    end

    test "indents newlines inside the exception message" do
      d = details { assert { (raise "hello\nsailor") == 1} }
      assert d == "\n    raise(\"hello\\nsailor\") raises RuntimeError: hello\n      sailor\n"
    end

    test "inspects values" do
      x = "flavor:\tvanilla"
      d = details { assert { x == "flavor:\tchocolate" } }
      # this means it's a literal slash plus t inside double quotes -- i.e. it shows the escaped (inspected) string
      assert d == "\n" + '    x is "flavor:\tvanilla"' + "\n"
    end

    test "indents unescaped newlines inside the inspected value" do
      weirdo = Object.new
      def weirdo.inspect
        "first\nsecond\nthird"
      end
      x = weirdo
      d = details { assert { x == "foo" }}
      assert d == "\n    x is first\n      second\n      third\n"
    end

  end
end
