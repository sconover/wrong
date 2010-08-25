require "./test/test_helper"

require "wrong/assert"
require "wrong/adapters/minitest"

regarding "a tool for capturing output" do

  test "captures stdout" do
    assert {
      capturing { puts "hi" } == "hi\n"
    }
  end

  test "captures stderr" do
    assert {
      capturing(:stderr) { $stderr.puts "hi" } == "hi\n"
    }
  end

  test "captures both" do
    out, err = capturing(:stdout, :stderr) do
       $stdout.puts "hi"
       $stderr.puts "bye"
    end

    assert { out == "hi\n"}
    assert { err == "bye\n"}

  end

  test "supports nesting" do
    outside = nil
    inside = nil
    outside = capturing do
      puts "bread"
      inside = capturing do
        puts "ham"
      end
      puts "more bread"
    end

    assert { inside == "ham\n"}
    assert { outside == "bread\nham\nmore bread\n"}
  end


  test "bails if stream was reassigned" do
    e = rescuing do
      capturing do
        $stdout = StringIO.new # uh-oh!
      end
    end
    assert { e.message =~ /^stdout was reassigned/ }
  end


end
