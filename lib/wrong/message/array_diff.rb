require "diff/lcs"
require "wrong/failure_message"

module Wrong
  class ArrayDiff < FailureMessage::Formatter
    register # tell FailureMessage::Formatter about us

    def match?
      predicate.is_a?(Predicated::Equal) &&
              arrayish?(predicate.left) &&
              arrayish?(predicate.right)
    end

    def arrayish?(object)
      # in some Rubies, String is Enumerable
      object.is_a?(Enumerable) && !(object.is_a?(String) || object.is_a?(Hash))
    end

    def describe
      left_str, right_str, diff_str = compute_and_format(predicate.left, predicate.right)

      message = "\n"
      message << left_str + "\n"
      message << right_str + "\n"
      message << diff_str + "\n"
      message

    end

    def compute_and_format(left, right)
      diffs = Diff::LCS.sdiff(left, right)

      left_arr = []
      right_arr = []
      diff_arr = []

      diffs.each do |diff|
        left_elem = diff.old_element.nil? ? "nil" : diff.old_element.inspect
        right_elem = diff.new_element.nil? ? "nil" : diff.new_element.inspect

        max_length = [left_elem.length, right_elem.length].max
        left_arr << left_elem.ljust(max_length) unless diff.action == "+"
        right_arr << right_elem.ljust(max_length) unless diff.action == "-"
        diff_arr << (diff.action == "=" ? " ".ljust(max_length) : "^".ljust(max_length))
      end


      diff_str = " " + diff_arr.join("  ") + " "

      [format(left_arr), format(right_arr), diff_str]
    end

    def format(thing)
      str = ""
      if thing.is_a?(Array)
        str << "["
        thing.each_with_index do |item, i|
          str << format(item)
          str << ", " unless i == thing.length-1
        end
        str << "]"
      else
        str << thing
      end
      str
    end

  end
end
