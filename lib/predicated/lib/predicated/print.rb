module Predicated
  module PrintSupport
    def inspect(indent="")
      indent + to_s
    end

    private
    def part_to_s(thing)
      part_to_str(thing) {|thing| thing.to_s}
    end
    
    def part_inspect(thing, indent="")
      part_to_str(thing, indent) {|thing| thing.inspect(indent)}
    end
    
    def part_to_str(thing, indent="")
      if thing.is_a?(String)
        "'#{thing}'"
      elsif thing.is_a?(Numeric) || thing.is_a?(TrueClass) || thing.is_a?(FalseClass)
        thing.to_s
      elsif thing.is_a?(Binary)
        yield(thing)
      elsif thing.nil?
        "nil"
      else
        "#{thing.class.name}{'#{thing.to_s}'}"
      end
    end
  end

  class Unary < Predicate
    include PrintSupport
    def to_s
      "#{self.class.shorthand}(#{part_to_s(inner)})"
    end    
  end
  
  class Binary < Predicate
    include PrintSupport
    def to_s
      "#{self.class.shorthand}(#{part_to_s(left)},#{part_to_s(right)})"
    end
  end
  
  module ContainerToString
    def inspect(indent="")
      next_indent = indent + " " + " "
      
      str = "#{indent}#{self.class.shorthand}(\n"
      str << "#{part_inspect(left, next_indent)},\n"
      str << "#{part_inspect(right, next_indent)}\n"
      str << "#{indent})"
      str << "\n" if indent == ""
      
      str
    end
  end
  
  class And; include ContainerToString end
  class Or; include ContainerToString end
  
end
