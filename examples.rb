puts "RUBY_VERSION=#{RUBY_VERSION}"
puts

require "rubygems"
require "bundler"
Bundler.setup

require "./lib/wrong"

include Wrong::Assert

Wrong.config[:color] = true

def failing
  e = rescuing do
    yield
  end
  puts e
  puts
end

# ignore all the "failing" statements in this file; they're so the failed assertions don't exit the process

failing { assert {2==1} }

failing { x = 7; y = 10; assert { x == 7 && y == 11 } }

failing do
  age = 24
  name = "Gaga"
  assert { age >= 18 && ["Britney", "Snooki"].include?(name) }
end

failing { deny{'abc'.include?('bc')} }


#require "wrong/message/string_diff"  TODO: make string_diff use "diff-lcs" not "diff" gem
failing do
  assert { "the quick brown fox jumped over the lazy dog" ==
           "the quick brown hamster jumped over the lazy gerbil" }
end

require "wrong/message/array_diff"
failing do
  assert { ["venus", "mars", "pluto", "saturn"] ==
           ["venus", "earth", "pluto", "neptune"] }
end

failing do
  assert{ rescuing{raise "vanilla"}.message == "chocolate" }
end

@foo = "bar"
class Foo
  def initialize(*args)
  end
end

failing { assert { Foo.new(1, Foo.new(3,4) ,3) == 4  } }

assert { capturing { puts "hi" } == "hi\n" }
assert { capturing(:stderr) { $stderr.puts "hi" } == "hi\n" }

out, err = capturing(:stdout, :stderr) do
  print "hi"
  $stderr.print "bye"
end
assert { out == "hi" and err == "bye"}

failing do
  time = 6
  money = 27
  assert { time == money }
end
