# run this file to see some sample Wrong failures

puts "RUBY_VERSION=#{RUBY_VERSION}"
puts

require "rubygems"
require "bundler"
Bundler.setup

require "./lib/wrong"
include Wrong

Wrong.config.color # or just put the line "color" in a file called ".wrong" in the current dir

def example(name = nil)
  puts "\n=== Example#{":" if name} #{name}"
  e = rescuing do
    yield
  end
  puts e
  puts
end

# ignore all the "example" statements in this file; they're so the failed assertions don't exit the process

example do
  assert {2==1}
end

example do
  x = 7; y = 10; assert { x == 7 && y == 11 }
end

example do
  age = 24
  name = "Gaga"
  assert { age >= 18 && ["Britney", "Snooki"].include?(name) }
end

example do
  assert { 'hand'.include?('bird') }
end

example do
  deny { 'abc'.include?('bc') }
end

example do
  assert { "the quick brown fox jumped over the lazy dog" == "the quick brown hamster jumped over the lazy gerbil" }
end

example do
  fun_planets = ["venus", "mars", "pluto", "saturn"]
  smart_planets = ["venus", "earth", "pluto", "neptune"]
  assert { fun_planets == smart_planets }
end

ex = rescuing{raise "vanilla"}
example { assert{ ex.message == "chocolate" } }

example do
  assert { rescuing { raise "vanilla" }.message == "chocolate" }
end

example do
  assert{ rescuing{raise "vanilla"}.message == "chocolate" }
end

@foo = "bar"
class Foo
  def initialize(*args)
  end
end

example do
  assert { Foo.new(1, Foo.new(3,4) ,3) == 4  }
end

assert { capturing { puts "hi" } == "hi\n" }
assert { capturing(:stderr) { $stderr.puts "hi" } == "hi\n" }

out, err = capturing(:stdout, :stderr) do
  print "hi"
  $stderr.print "bye"
end
assert { out == "hi" and err == "bye"}

example do
  time = 6
  money = 27
  assert { time == money }
end

example do
  assert { "123".reverse == "323" }
end

example do
  hash = {:flavor => "vanilla"}
  exception_with_newlines = Exception.new(hash.to_yaml.chomp)
  assert("showing indentation of details") { rescuing { raise exception_with_newlines }.message.include?(":flavor: chocolate") }
end

example "indentation of long values" do
  alphabet = "abcdefghijklmnopqrstuvwxyz"
  assert { (alphabet * 10).include? "123"  }
end

example "indentation of long values" do
  hash = {}
  100.times do
    hash[(rand * 1000).to_i] = (rand * 1000).to_i
  end
  assert { hash["abc"] }
end

example "the d method" do
  x = 7
  d { x * 2 }
end
