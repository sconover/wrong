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

    test "fails if it can't find an assertion" do
      chunk = Chunk.new(__FILE__, __LINE__ + 1); <<-CODE
        yielding { x == 5 }
      CODE
      error = get_error {
        chunk.claim
      }
      assert error.message.include?("Could not find assertion")
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
end

regarding Sexp do
  regarding "#doop" do
    test "deeply duplicates the sexp" do
      original = RubyParser.new.parse("x == 5")
      duplicate = original.doop
      assert(original.object_id != duplicate.object_id)
      assert(original[1].object_id != duplicate[1].object_id)
      assert(original[1][3].object_id != duplicate[1][3].object_id)
      assert(original[3].object_id != duplicate[3].object_id)
    end
  end

  regarding "#to_ruby" do
    test "converts the sexp to ruby code" do
      sexp = RubyParser.new.parse("x == 5")
      assert sexp.to_ruby == "(x == 5)"
    end

    test "leaves the original sexp alone" do
      sexp = RubyParser.new.parse("x == 5")
      assert sexp.to_ruby == "(x == 5)"
      assert sexp.to_ruby == "(x == 5)"
    end
  end

  regarding "#assertion? with a question mark" do
    test "matches an sexp that looks like assert { }" do
      sexp = RubyParser.new.parse("assert { true }")
      assert sexp.assertion?
    end
    
    test "matches an sexp that looks like assert(message) { }" do
      sexp = RubyParser.new.parse("assert('hi') { true }")
      assert sexp.assertion?
    end

    test "matches an sexp that looks like deny { }" do
      sexp = RubyParser.new.parse("deny { false }")
      assert sexp.assertion?
    end

    test "doesn't match an sexp that calls assert without a block" do
      sexp = RubyParser.new.parse("assert(true)")
      assert !sexp.assertion?
    end

    test "doesn't match a normal sexp" do
      sexp = RubyParser.new.parse("x == 5")
      assert !sexp.assertion?
    end
  end

  regarding "#assertion" do
    test "matches a top-level sexp that looks like assert { }" do
      sexp = RubyParser.new.parse("assert { true }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end
    
    test "matches a nested sexp that looks like assert { }" do
      sexp = RubyParser.new.parse("nesting { assert { true } }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end

    test "matches the first nested sexp that looks like assert { }" do
      sexp = RubyParser.new.parse("nesting { assert { true } or assert { false } }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end
  end

end
