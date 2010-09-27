require "./test/test_helper"

require "wrong/adapters/minitest"

describe "a tool for capturing output" do

  include Wrong

  it "captures stdout" do
    assert {
      capturing { puts "hi" } == "hi\n"
    }
  end

  it "captures stderr" do
    assert {
      capturing(:stderr) { $stderr.puts "hi" } == "hi\n"
    }
  end

  it "captures both" do
    out, err = capturing(:stdout, :stderr) do
       $stdout.puts "hi"
       $stderr.puts "bye"
    end

    assert { out == "hi\n"}
    assert { err == "bye\n"}

  end

  it "supports nesting" do
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


  it "bails if stream was reassigned" do
    e = rescuing do
      capturing do
        $stdout = StringIO.new # uh-oh!
      end
    end
    assert { e.message =~ /^stdout was reassigned/ }
  end


end
