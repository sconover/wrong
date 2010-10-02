require "diff/lcs"

module Wrong
  module Assert

    overridable do
    def failure_message(method_sym, block, predicate)
      message = super

      if predicate.is_a?(Predicated::Equal) && 
         predicate.left.is_a?(Enumerable) &&
         predicate.right.is_a?(Enumerable)

        diffs = Diff::LCS.sdiff(predicate.left, predicate.right)
        # left_offset = 0
        left_arr = []
        right_arr = []
        diff_arr = []
        
        diffs.each do |diff|
          left_elem = diff.old_element.nil? ? "nil" : diff.old_element.inspect
          right_elem = diff.new_element.nil? ? "nil" : diff.new_element.inspect
          
          max_length = [left_elem.length, right_elem.length].max
          left_arr << left_elem.ljust(max_length) unless diff.action == "+"
          right_arr << right_elem.ljust(max_length) unless diff.action == "-"
          diff_arr <<  (diff.action == "=" ? " ".ljust(max_length) : "^".ljust(max_length))
        end
        
        
        left_str, right_str, diff_str = ArrayDiff.compute_and_format(predicate.left, predicate.right)

        message << "\n\narray diff:\n"
        message << left_str + "\n"
        message << right_str + "\n"
        message << diff_str + "\n"
      end
      
      message
    end
    end

    module ArrayDiff
      def self.compute_and_format(left, right)
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
          diff_arr <<  (diff.action == "=" ? " ".ljust(max_length) : "^".ljust(max_length))
        end
        

        [format(left_arr), 
         format(right_arr),
          " " + diff_arr.join("  ") + " "]
      end
      
      def self.format(thing)
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
end
