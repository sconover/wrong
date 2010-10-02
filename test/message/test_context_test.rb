require "./test/test_helper"
require "wrong/assert"
require "wrong/message/test_context"

xdescribe "showing the lines just above where the failure occurs, so you have some context" do

  include Wrong::Assert
  
  it "you can see test method all the way back to the start of the test, plus an indication of where the failure was" do
    a = 1
    b = 2
    c = 1
    assert{ a == c }
    begin
      assert{ a == b }
    rescue Wrong::Assert::AssertionFailedError => e
      puts e
      assert do
        e.message.include?(
%{  it "you can see test method all the way back to the start of the test, plus an indication of where the failure was" do
    a = 1
    b = 2
    c = 1
    assert{ a == c }
    begin
      assert{ a == b }      ASSERTION FAILURE test/include_test_context_test.rb:15}
        )
      end
      
      deny {e.message.include?("works with it too")}
      deny {e.message.include?("test_works_with_test_undercore")}
    end
  end
  
  it "works with it too" do
    begin
      assert{ 1 == 2 }
    rescue Wrong::Assert::AssertionFailedError => e
      assert do
        e.message.include?(
%{  it "works with it too" do
    begin
      assert{ 1 == 2 }      ASSERTION FAILURE test/include_test_context_test.rb:36}
        )
      end
      
      deny {e.message.include?("you can see test method")}
      deny {e.message.include?("test_works_with_test_undercore")}
    end
  end
  
  def test_works_with_test_undercore_too
    begin
      assert{ 1 == 2 }
    rescue Wrong::Assert::AssertionFailedError => e
      assert do
        e.message.include?(
%{  def test_works_with_test_undercore_too
    begin
      assert{ 1 == 2 }      ASSERTION FAILURE test/include_test_context_test.rb:53}
        )
      end
      
      deny {e.message.include?("you can see test method")}
      deny {e.message.include?("works with it too")}
    end
  end
  
end
