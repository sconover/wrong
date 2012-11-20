require "./test/test_helper"
require "wrong/assert"
require "wrong/adapters/minitest"

describe "advanced assert features" do

  def assert_later(&p)
    assert(&p)
  end

  # dunno why, but this fails under JRuby (both 1.8 and 1.9)
  unless Object.const_defined? :JRuby
    it "is possible (but hardly advisable) to define procs in different places from the assert call" do
      x = 10
      e = get_error do
        assert_later { x > 10 }
      end

      assert(e.message =~ /Expected assert_later { \(x > 10\) }, but.*x is 10/m, e.message)
    end
  end

  it "can parse a here doc defined inside the block" do
    # todo: test in Chunk too
    assert { "123\n456\n" == <<-TEXT
123
456
    TEXT
    }
  end

  it "can parse a here doc defined outside the block" do
    # todo: test in Chunk too
    assert { "123\n456\n" == <<-TEXT }
123
456
    TEXT
  end

  it "finds the file to parse even when inside a chdir to a child directory" do
    e = get_error do
      Dir.chdir("test") do
        assert { (1 + 2) == 5 }
      end
    end
    assert { e.message.include? "Expected ((1 + 2) == 5), but" }
  end

  # todo: test for finding it if you'd changed dirs into a parent or sibling or cousin dir

  it "can compare two hashes" do
    assert { {1=>2} == {1=>2} }
    unless RUBY_VERSION < "1.9"
      assert do
        {a:2} == {a:2}
      end
    end
  end
end
