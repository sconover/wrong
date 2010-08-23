require "./test/test_helper"
require "wrong/sexp_ext"

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

  def parse(ruby)
    RubyParser.new.parse(ruby)
  end

  regarding "#to_ruby" do
    test "converts the sexp to ruby code" do
      sexp = parse("x == 5")
      assert sexp.to_ruby == "(x == 5)"
    end

    test "leaves the original sexp alone" do
      sexp = parse("x == 5")
      assert sexp.to_ruby == "(x == 5)"
      assert sexp.to_ruby == "(x == 5)" # intended
    end
  end

  regarding "#assertion? with a question mark" do
    test "matches an sexp that looks like assert { }" do
      sexp = parse("assert { true }")
      assert sexp.assertion?
    end

    test "matches an sexp that looks like assert(message) { }" do
      sexp = parse("assert('hi') { true }")
      assert sexp.assertion?
    end

    test "matches an sexp that looks like deny { }" do
      sexp = parse("deny { false }")
      assert sexp.assertion?
    end

    test "doesn't match an sexp that calls assert without a block" do
      sexp = parse("assert(true)")
      assert !sexp.assertion?
    end

    test "doesn't match a normal sexp" do
      sexp = parse("x == 5")
      assert !sexp.assertion?
    end
  end

  regarding "#assertion" do
    test "matches a top-level sexp that looks like assert { }" do
      sexp = parse("assert { true }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end

    test "matches a nested sexp that looks like assert { }" do
      sexp = parse("nesting { assert { true } }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end

    test "matches the first nested sexp that looks like assert { }" do
      sexp = parse("nesting { assert { true } or assert { false } }")
      code = sexp.assertion.to_ruby
      assert code == "assert { true }"
    end
  end

end
