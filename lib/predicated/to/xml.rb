require "predicated/predicate"

module Predicated

  module ContainerToXml
    private
    def to_xml_with_tag_name(indent, tag_name)
      inner = %{\n#{left.to_xml(indent + "  ")}\n#{right.to_xml(indent + "  ")}}
      "#{indent}<#{tag_name}>#{inner}\n#{indent}</#{tag_name}>"
    end
  end
  
  class And
    include ContainerToXml
    def to_xml(indent="")
      to_xml_with_tag_name(indent, "and")
    end
  end

  class Or
    include ContainerToXml
    def to_xml(indent="")
      to_xml_with_tag_name(indent, "or")
    end
  end

  class Not
    def to_xml(indent="")
      "#{indent}<not>\n#{inner.to_xml(indent + "  ")}\n#{indent}</not>"
    end
  end
  
  class Operation
    def to_xml(indent="")
      "#{indent}<#{tag_name}><left>#{escape(left)}</left><right>#{escape(right)}</right></#{tag_name}>"
    end
    
    private 
    
    CONVERSION_TABLE = [
       ['&', '&amp;'],
       ['<', '&lt;'],
       ['>', '&gt;'],
       ["'", '&apos;'],
       ['"', '&quot;']
    ]
    
    #it's fast.  see http://groups.google.com/group/ruby-talk-google/browse_thread/thread/c0280bab8a037184/9b8ca81c2607189d?hl=en&ie=UTF-8
    def escape(value)
      if value.class == String
        value.gsub(/['"&<>]/) do |match|
          CONVERSION_TABLE.assoc(match).last
        end
      else
        value
      end
    end
  end

  class Equal; private; def tag_name; "equal" end end
  class LessThan; private; def tag_name; "lessThan" end end
  class GreaterThan; private; def tag_name; "greaterThan" end end
  class LessThanOrEqualTo; private; def tag_name; "lessThanOrEqualTo" end end
  class GreaterThanOrEqualTo; private; def tag_name; "greaterThanOrEqualTo" end end
  

end