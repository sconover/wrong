require "wrong/failure_message"

module Wrong
  class StringComparison
    @@window = [64, Terminal.width - 20].min
    @@prelude = 12

    def self.window
      @@window
    end

    def self.window=(val)
      @@window = val
    end

    def self.prelude
      @@prelude
    end

    def self.prelude=(val)
      @@prelude = val
    end

    def initialize(first, second)
      @first = first
      @second = second
    end

    def same?
      @first == @second
    end

    def different_at
      if (@first.nil? || @second.nil?)
        0
      else
        i = 0
        while (i < @first.size && i < @second.size)
          if @first[i] != @second[i]
            break
          end
          i += 1
        end
        return i
      end
    end

    def message
      "Strings differ at position #{different_at}:\n" +
              " first: #{chunk(@first)}\n" +
              "second: #{chunk(@second)}"
    end

    def chunk(s)
      prefix, middle, suffix = "...", "", "..."

      start = different_at - @@prelude
      if start < 0
        prefix = ""
        start = 0
      end

      stop = start + @@window
      if stop >= s.size
        suffix = ""
        stop = s.size
      end

      [prefix, s[start...stop].inspect, suffix].join
    end
  end

  class StringComparisonFormatter < FailureMessage::Formatter
    register # tell FailureMessage::Formatter about us

    def match?
      predicate.is_a?(Predicated::Equal) &&
              predicate.left.is_a?(String) &&
              predicate.right.is_a?(String)
    end

    def describe
      comparison = Wrong::StringComparison.new(predicate.left, predicate.right)
      "\n" + comparison.message
    end
  end

end
