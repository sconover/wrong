require "predicated/predicate"

module Predicated

  require_gem_version("nokogiri", "1.4.3")

  module Predicate
    def self.from_xml(xml_str)
      NodeToPredicate.convert(Nokogiri::XML(xml_str).root)
    end
    
    module NodeToPredicate
      OPERATION_TAG_TO_CLASS = {
        "equal" => Equal, 
        "greaterThan" => GreaterThan, 
        "lessThan" => LessThan, 
        "greaterThanOrEqualTo" => GreaterThanOrEqualTo, 
        "lessThanOrEqualTo" => LessThanOrEqualTo
      }
      
      def self.convert(node)
        
        node = next_non_text_node(node)
        
        if node.name == "and"
          left = next_non_text_node(node.children[0])
          right = next_non_text_node(left.next)
          And.new(convert(left), convert(right))
        elsif node.name == "or"
          left = next_non_text_node(node.children[0])
          right = next_non_text_node(left.next)
          Or.new(convert(left), convert(right))
        elsif node.name == "not"
          inner = next_non_text_node(node.children[0])
          Not.new(convert(inner))
        elsif operation_class=OPERATION_TAG_TO_CLASS[node.name]
          left = next_non_text_node(node.children[0])
          right = next_non_text_node(left.next)
          operation_class.new(left.text, right.text)
        else
          raise DontKnowWhatToDoWithThisXmlTag.new(node.name)
        end
      end
      
      def self.next_non_text_node(node)
        while node.text?
          node = node.next
        end
        node
      end

    end
    
    class DontKnowWhatToDoWithThisXmlTag < StandardError
      def initialize(xml_tag)
        super("don't know what to do with #{xml_tag}")
      end
    end

  end
end