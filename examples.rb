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

failing { assert {2==1} }

failing { x = 7; y = 10; assert { x == 7 && y == 11 } }

failing { deny{'abc'.include?('bc')} }

failing do
  assert{ rescuing{raise "vanilla"}.message == "chocolate" }
end

@foo = "bar"
class Foo
  def initialize(*args)
  end
end

failing { assert { Foo.new(1, Foo.new(3,4) ,3) == 4  } }

