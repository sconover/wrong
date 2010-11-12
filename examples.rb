# run this file to see some sample Wrong failures

puts "RUBY_VERSION=#{RUBY_VERSION}"
puts

require "rubygems"
require "bundler"
Bundler.setup

require "./lib/wrong"
include Wrong

Wrong.config.color # or just put the line "color" in a file called ".wrong" in the current dir

def failing
  e = rescuing do
    yield
  end
  puts e
  puts
end

# ignore all the "failing" statements in this file; they're so the failed assertions don't exit the process

failing do
  assert {2==1}
end

failing do
  x = 7; y = 10; assert { x == 7 && y == 11 }
end

failing do
  age = 24
  name = "Gaga"
  assert { age >= 18 && ["Britney", "Snooki"].include?(name) }
end

failing do
  assert { 'hand'.include?('bird') }
end

failing do
  deny { 'abc'.include?('bc') }
end

failing do
  assert { "the quick brown fox jumped over the lazy dog" == "the quick brown hamster jumped over the lazy gerbil" }
end

require "wrong/message/array_diff"
failing do
  fun_planets = ["venus", "mars", "pluto", "saturn"]
  smart_planets = ["venus", "earth", "pluto", "neptune"]
  assert { fun_planets == smart_planets }
end

ex = rescuing{raise "vanilla"}
failing { assert{ ex.message == "chocolate" } }

failing do
  assert { rescuing { raise "vanilla" }.message == "chocolate" }
end

failing do
  assert{ rescuing{raise "vanilla"}.message == "chocolate" }
end

@foo = "bar"
class Foo
  def initialize(*args)
  end
end

failing do
  assert { Foo.new(1, Foo.new(3,4) ,3) == 4  }
end

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

failing do
  assert { "123".reverse == "323" }
end

failing do
  hash = {:flavor => "vanilla"}
  exception_with_newlines = Exception.new(hash.to_yaml)
  assert("showing indentation of details") { rescuing { raise exception_with_newlines }.message.include?(":flavor: chocolate") }
end

x = 7
d { x * 2 }

