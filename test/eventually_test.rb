# based on
# * https://gist.github.com/1228927
# * https://github.com/pivotal/selenium/blob/master/lib/selenium/wait_for.rb
# see
# http://rubyforge.org/pipermail/rspec-users/2011-September/020575.html

here = File.expand_path(File.dirname(__FILE__))

require "#{here}/test_helper"
require "wrong/assert"
require "wrong/helpers"
require "wrong/d"

require "wrong/eventually"

# todo: move this to a monkey patch file
class Object
  unless Object.method_defined? :singleton_class
    def singleton_class
       class << self
         self
       end
    end
  end
end

describe "eventually" do
  include Wrong::Eventually
  include Wrong::Assert
  include Wrong::Helpers
  include Wrong::D

  # rolling our own mock clock and stubbing framework since we want these
  # tests to run in MiniTest or in any version of RSpec

  class ::Time
    class << self
      alias_method :real_now, :now
      def now
        # puts "in new now; original_now = #{original_now}, @now = #{@now}"
        @now ||= real_now
      end
      def now= new_now
        @now = new_now
      end
    end
  end

  def stub_it(receiver, method_name, &block)
    receiver.singleton_class.send(:define_method, method_name, &block)
  end

  def unstub_it(receiver, method_name)
    receiver.singleton_class.send(:remove_method, method_name)
  end

  before do
    stub_it(self, :sleep) do |secs|
      Time.now += secs
    end
  end

  after do
    unstub_it(self, :sleep)
  end

  it "requires a block" do
    e = rescuing {
      eventually
    }
    assert { e.message == Wrong::Eventually::NO_BLOCK_PASSED }
    assert { e.message =~ /pass a block/ }
  end

  it "returns immediately if the block evaluates to true" do
    original_now = Time.now
    eventually { true }
    assert { Time.now == original_now }
  end

  it "raises an exception after 5 seconds of being false" do
    original_now = Time.now
    e = rescuing do
      eventually { false }
    end
    deny { e.nil? }
    assert { Time.now == original_now + 5}
  end

  it "calls the block every 0.25 seconds" do
    original_now = Time.now
    called_at = []
    rescuing {
      eventually {
        called_at << (Time.now - original_now)
        false
      }
    }
    assert { called_at.uniq == [
      0.0, 0.25, 0.5, 0.75,
      1.0, 1.25, 1.5, 1.75,
      2.0, 2.25, 2.5, 2.75,
      3.0, 3.25, 3.5, 3.75,
      4.0, 4.25, 4.5, 4.75,
    ] }
  end

  it "returns after the condition is false for a while then true" do
    original_now = Time.now
    eventually {
      # cleverly, I am asserting that time has passed
      Time.now >= original_now + 2
    }
    assert {
      Time.now == original_now + 2
    }
  end

  it "raises a detailed Wrong exception if the result keeps being false" do
    e = rescuing do
      eventually { false }
    end
    assert { e.message == "Expected false" }

    x = 1
    e = rescuing do
      eventually do
        x + 2 == 4
      end
    end
    assert { e.message == "Expected ((x + 2) == 4), but\n    (x + 2) is 3\n    x is 1\n" }
  end

  describe "if the block raises an exception" do
    it "for 5 seconds, it raises that exception" do
      original_now = Time.now
      e = rescuing do
        eventually { raise "nope" }
      end
      deny { e.nil? }
      assert { Time.now == original_now + 5}
      assert { e.is_a? RuntimeError }
      assert { e.message == "nope" }
    end

    it "but then returns true, it succeeds silently" do
      original_now = Time.now
      eventually {
         if Time.now < original_now + 2
           raise "not yet"
         else
           true
         end
      }
      assert {
        Time.now == original_now + 2
      }
    end
  end

  describe "takes an options hash" do
    it "that can change the timeout" do
      original_now = Time.now
      rescuing {
        eventually(:timeout => 2) { false }
      }
      assert {
        Time.now == original_now + 2
      }
    end

    it "that can change the delay" do
      original_now = Time.now
      called_at = []
      rescuing {
        eventually(:delay => 1.5) {
          called_at << (Time.now - original_now)
          false
        }
      }
      assert { called_at.uniq == [0.0, 1.5, 3.0, 4.5] }
    end
  end
end
