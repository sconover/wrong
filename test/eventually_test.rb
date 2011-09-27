# based on 
# * https://gist.github.com/1228927
# * https://github.com/pivotal/selenium/blob/master/lib/selenium/wait_for.rb
# see
# http://rubyforge.org/pipermail/rspec-users/2011-September/020575.html

require "./test/test_helper"
require "wrong/assert"
require "wrong/helpers"
require "wrong/d"
require 'rspec/mocks'

require "wrong/eventually"

# this test really does require rspec

describe "eventually" do
  include Wrong::Eventually
  include Wrong::Assert
  include Wrong::Helpers
  include Wrong::D

  before do
    @fake_now = Time.now
    Time.stub!(:now).and_return { @fake_now }
    self.stub!(:sleep).and_return do |secs| 
      @fake_now += secs
    end
  end
    
  it "requires a block" do
    rescuing {
      eventually
    }.message.should == "please pass a block to the eventually method"
  end

  it "returns immediately if the block evaluates to true" do
    original_now = @fake_now
    eventually { true }
    assert { @fake_now == original_now }
  end

  it "raises an exception after 5 seconds of being false" do
    original_now = @fake_now
    e = rescuing do
      eventually { false }
    end
    deny { e.nil? }
    assert { @fake_now == original_now + 5}
  end
  
  it "puts the elapsed time in the exception message"
  # assert { e.message =~ /\(after 5 sec\)$/}
  
  
  it "returns after the condition is false for a while then true" do
    original_now = @fake_now
    eventually {
      # cleverly, I am asserting that time has passed
      @fake_now >= original_now + 2
    }
    assert {
      @fake_now == original_now + 2
    }
  end

  it "raises a detailed Wrong exception if the result keeps being false" do
    original_now = @fake_now
    e = rescuing do
      eventually { false }
    end
    assert { e.is_a? Wrong::Assert::AssertionFailedError }
    assert { e.message == "Expected false" }
    
    x = 1
    e = rescuing do
      eventually { x + 2 == 4 }
    end
    assert { e.message == "Expected ((x + 2) == 4), but\n    (x + 2) is 3\n    x is 1\n" }
  end
  
  describe "if the block raises an exception" do
    it "for 5 seconds, it raises that exception" do
      original_now = @fake_now
      e = rescuing do
        eventually { raise "nope" }
      end
      deny { e.nil? }
      assert { @fake_now == original_now + 5}
      assert { e.is_a? RuntimeError }
      assert { e.message == "nope" }
    end

    it "but then returns true, it succeeds silently" do
      original_now = @fake_now
      eventually {
         if @fake_now < original_now + 2
           raise "not yet"
         else
           true
         end
      }
      assert {
        @fake_now == original_now + 2
      }
    end
  end
  
  describe "passes a context hash to the block" do
    it "that influences the error message"
  end
  
  describe "takes an options hash" do
    it "that can change the timeout"
    it "that can change the delay"
  end
end
