require "diff"

module Wrong
  module Assert
    
    def failure_message(method_sym, block, predicate)
      message = super
      
      if predicate.is_a?(Predicated::Equal) && 
         predicate.left.is_a?(String) &&
         predicate.right.is_a?(String)
        
        problems = predicate.left.diff(predicate.right)
        max_length = [predicate.left.length, predicate.right.length].max
        
        message << "\n\nstring diff:\n"
        message << StringDiff.string_with_diff(predicate.left, problems, max_length, "-")
        message << StringDiff.string_with_diff(predicate.right, problems, max_length, "+")
      end
      
      message
    end
    
    module StringDiff
      def self.string_with_diff(original_str, problems, max_length, sign)
        str = ""
        str << original_str.gsub("\n", "\\n").gsub("\t", "\\t").gsub("\r", "\\r") + "\n"
        str << StringDiff.problems_to_carrot_string(problems, max_length, sign) + "\n"
        str
      end
      
      def self.problems_to_carrot_string(problems, length, sign)
        carrot_string = " " * length
        problems.diffs.first.each do |add_subtract, position, character_code|
          carrot_string[position] = "^" if sign == add_subtract
        end
        carrot_string
      end
    end

  end
end
