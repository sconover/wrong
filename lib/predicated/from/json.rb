require "predicated/predicate"

module Predicated

  require_gem_version("json", "1.1.9")

  module Predicate
    def self.from_json_str(json_str)
      from_json_struct(JSON.parse(json_str))
    end
    
    def self.from_json_struct(json_struct)
      JsonStructToPredicate.convert(json_struct)
    end
    
    module JsonStructToPredicate
      SIGN_TO_CLASS = {
        "==" => Equal, 
        ">" => GreaterThan, 
        "<" => LessThan, 
        ">=" => GreaterThanOrEqualTo, 
        "<=" => LessThanOrEqualTo
      }
      
      def self.convert(json_struct)        
        if json_struct.is_a?(Array)
          left, sign, right = json_struct
          if operation_class=SIGN_TO_CLASS[sign]
            operation_class.new(left, right)
          else
            raise DontKnowWhatToDoWithThisJson.new(json_struct)
          end
        elsif json_struct.is_a?(Hash)
          if left_and_right=json_struct["and"]
            left, right = left_and_right
            And.new(convert(left), convert(right))
          elsif left_and_right=json_struct["or"]
            left, right = left_and_right
            Or.new(convert(left), convert(right))
          elsif inner=json_struct["not"]
            Not.new(convert(inner))
          else
            raise DontKnowWhatToDoWithThisJson.new(json_struct)
          end
        else
          raise DontKnowWhatToDoWithThisJson.new(json_struct)
        end
      end
      
    end
    
    class DontKnowWhatToDoWithThisJson < StandardError
      def initialize(json_struct)
        super("don't know what to do with #{JSON.generate(json_struct)}")
      end
    end

  end
end