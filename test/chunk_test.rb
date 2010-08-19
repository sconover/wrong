require "./test/test_helper"
require "wrong/chunk"

regarding Wrong::Chunk do
  regarding "#from_block" do
    if RUBY_VERSION < "1.9"
      test "in Ruby 1.8, it reads the source location from the call stack"
    else
      test "in Ruby 1.9, it reads the source location from the block"
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
    test "reads a statement on a line by itself"
    test "reads a statement on multiple lines"
    test "fails if there's a stray close-block symbol on the last line (sorry)"
  end

  regarding "#sexp" do
    test "memoizes"
    test "reads an assert statement on a line by itself"
    test "reads an assert statement on multiple lines"
    if RUBY_VERSION > "1.9"
      test "reads an assert statement that's nested inside another yield block on the same line (Ruby 1.9 only)"
      test "goes crazy if you try to nest two asserts on the same line"
    end
    test "fails if it can't find an assertion"
    test "fails if it can't find the file"
    test "fails if it can't parse the code"
  end

  regarding "#parts" do
    test "returns all unique sub-expressions of the main sexpression"
  end
end

regarding Sexp do
  regarding "#doop" do
    test "duplicates the sexp"
  end

  regarding "#to_ruby" do
    test "converts the sexp to ruby code"
    test "leaves the original sexp alone"
  end

  regarding "#assertion?" do
    test "matches an sexp that looks like assert { }"
    test "matches an sexp that looks like assert(message) { }" # todo
    test "matches an sexp that looks like deny { }"
    test "doesn't match an sexp that calls assert without a block"
    test "doesn't match a normal sexp"
  end

  regarding "#assertion" do
    test "matches a top-level sexp that looks like assert { }"
    test "matches a nested sexp that looks like assert { }"
    test "matches the first nested sexp that looks like assert { }"
  end

end
