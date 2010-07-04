require "test/test_helper"

require "wrong/assert"

apropos "failures" do
  
  before do
    @m = Module.new do
      extend Wrong::Assert
    end
  end
  
  def get_error
    error = nil
    begin
      yield
    rescue Exception => e
      error = e
    end
    e
  end
  
  apropos "simple" do
    test "raw boolean failure" do
      assert_match "false", get_error{@m.assert{false}}.message
      assert_match "true", get_error{@m.deny{true}}.message
    end
  
    test "equality failure" do
      assert_match "1 is not equal to 2", get_error{@m.assert{1==2}}.message
      assert_match "1 is equal to 1", get_error{@m.deny{1==1}}.message
    end
  
    test "failure of basic operations" do
      assert_match "1 is not greater than 2", get_error{@m.assert{1>2}}.message
      assert_match "2 is not less than 1", get_error{@m.assert{2<1}}.message
      assert_match "1 is not greater than or equal to 2", get_error{@m.assert{1>=2}}.message
      assert_match "2 is not less than or equal to 1", get_error{@m.assert{2<=1}}.message

      assert_match "2 is greater than 1", get_error{@m.deny{2>1}}.message
      assert_match "1 is less than 2", get_error{@m.deny{1<2}}.message
      assert_match "2 is greater than or equal to 1", get_error{@m.deny{2>=1}}.message
      assert_match "1 is less than or equal to 2", get_error{@m.deny{1<=2}}.message
    end
    
    class Color
      attr_reader :name
      def initialize(name)
        @name = name
      end
    
      def ==(other)
        other.is_a?(Color) && @name == other.name
      end
      
      def inspect
        "Color:#{@name}"
      end
    end
    
    test "object failure" do
      assert_match "'Color:red' is not equal to 2", get_error{@m.assert{Color.new("red")==2}}.message
    end
    
    test %{multiline assert block shouldn't look any different 
           than when there everything is on one line} do
      assert_match("1 is not equal to 2", get_error{@m.assert{
        1==
        2
      }}.message)
    end

  end
  
  apropos "accessing and printing values set outside of the assert" do
    test "use a value in the assert defined outside of it" do
      a = 1
      assert_match "1 is not equal to 2", get_error{@m.assert{a==2}}.message
      assert_match "1 is equal to 1", get_error{@m.deny{a==1}}.message
    end
  end
  
  apropos "the assert block has many statements" do
    test "only pay attention to the final statement" do
      assert_match("1 is not equal to 2", get_error{@m.assert{
        a = "aaa"
        b = 1 + 2
        c = ["foo", "bar"].length / 3
        if a=="aaa"
          b = 4
        end; 1==2
      }}.message)
    end
  end
end