require "./test/test_helper"
require "wrong/adapters/minitest"
require "wrong/message/string_comparison"

module Wrong
describe StringComparison do

  StringComparison = Wrong::StringComparison # so Ruby 1.9.1 can find it
  
  before do
    # crank the window and prelude down for these tests
    @old_window = StringComparison.window
    @old_prelude = StringComparison.prelude
    StringComparison.window = 16
    StringComparison.prelude = 8
  end

  after do
    StringComparison.window = @old_window
    StringComparison.prelude = @old_prelude
  end

  describe '#same?' do
    it "says identical empty strings are the same" do
      comparison = StringComparison.new("", "")
      assert { comparison.same? }
    end

    it "says identical non-empty strings are the same" do
      comparison = StringComparison.new("abc", "abc")
      assert { comparison.same? }
    end

    it "says two nils are the same" do
      comparison = StringComparison.new(nil, nil)
      assert { comparison.same? }
    end

    it "says a string is different from a different string" do
      comparison = StringComparison.new("abc", "xyz")
      deny { comparison.same? }
    end

    it "says a string is different from nil" do
      comparison = StringComparison.new("abc", nil)
      deny { comparison.same? }
    end

    it "says nil is different from a string" do
      comparison = StringComparison.new(nil, "abc")
      deny { comparison.same? }
    end
  end

  describe '#different_at' do
    describe "returns the location where two strings differ" do

      it "at the beginning of the strings" do
        assert { StringComparison.new("abc", "xyz").different_at == 0 }
      end

      it "at the middle of the strings" do
        assert { StringComparison.new("abc", "ayz").different_at == 1 }
      end

      it "when the first string is longer" do
        assert { StringComparison.new("abcd", "abc").different_at == 3 }
      end

      it "when the second string is longer" do
        assert { StringComparison.new("abc", "abcd").different_at == 3 }
      end

      it "with nil as the first string" do
        assert { StringComparison.new(nil, "abc").different_at == 0 }
      end

      it "with nil as the second string" do
        assert { StringComparison.new("abc", nil).different_at == 0 }
      end

    end
  end

  describe '#message' do
    def compare(first, second, expected_message)
      expected_message.strip!
      assert { StringComparison.new(first, second).message == expected_message }
    end

    it 'shows the whole of both strings when the difference is near the start' do
compare "abc", "xyz", <<-MESSAGE
Strings differ at position 0:
 first: "abc"
second: "xyz"
      MESSAGE
    end

    it 'shows ellipses when the difference is in the middle of a long string' do
      compare "abcdefghijklmnopqrstuvwxyz", "abcdefghijkl*nopqrstuvwxyz", <<-MESSAGE
Strings differ at position 12:
 first: ..."efghijklmnopqrst"...
second: ..."efghijkl*nopqrst"...
      MESSAGE
    end

    it 'shows ellipses when the difference is near the beginning of a long string' do
      compare "abcdefghijklmnopqrstuvwxyz", "a*cdefghijklmnopqrstuvwxyz", <<-MESSAGE
Strings differ at position 1:
 first: "abcdefghijklmnop"...
second: "a*cdefghijklmnop"...
      MESSAGE
    end

    it 'shows ellipses when the difference is near the end of a long string' do
      compare "abcdefghijklmnopqrstuvwxyz", "abcdefghijklmnopqrstuvw*yz", <<-MESSAGE
Strings differ at position 23:
 first: ..."pqrstuvwxyz"
second: ..."pqrstuvw*yz"
      MESSAGE
    end

    it 'allows user to override the default window size' do
      original = StringComparison.window
      begin
        StringComparison.window = 10
        compare "abcdefghijklmnopqrstuvwxyz", "a*cdefghijklmnopqrstuvwxyz", <<-MESSAGE
Strings differ at position 1:
 first: "abcdefghij"...
second: "a*cdefghij"...
        MESSAGE
      ensure
        StringComparison.window = original
      end
    end

    it 'allows user to override the prelude size' do
      original = StringComparison.prelude
      begin
        StringComparison.prelude = 2
        compare "abcdefghijklmnopqrstuvwxyz", "abcdefghijkl*nopqrstuvwxyz", <<-MESSAGE
Strings differ at position 12:
 first: ..."klmnopqrstuvwxyz"
second: ..."kl*nopqrstuvwxyz"
        MESSAGE
      ensure
        StringComparison.prelude = original
      end
    end
  end
  end

  describe "Wrong integration" do
    it "works" do
      error = rescuing do
        assert { "xyz" == "abc" }
      end
      assert { error.message =~ /Strings differ at position 0:/ }
    end
  end
end
