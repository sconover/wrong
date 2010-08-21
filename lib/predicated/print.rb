module Predicated
  module PrintSupport
    def to_s(indent="")
      indent + inspect
    end

    private
    def part_inspect(thing)
      part_to_str(thing) {|thing| thing.inspect}
    end
    
    def part_to_s(thing, indent="")
      part_to_str(thing, indent) {|thing| thing.to_s(indent)}
    end
    
    def part_to_str(thing, indent="")
      if thing.is_a?(String)
        "'#{thing}'"
      elsif thing.is_a?(Numeric) || thing.is_a?(TrueClass) || thing.is_a?(FalseClass)
        thing.to_s
      elsif thing.is_a?(Binary)
        yield(thing)
      else
        "#{thing.class.name}{'#{thing.to_s}'}"
      end
    end
  end

  class Unary
    include PrintSupport
    def inspect
      "#{self.class.shorthand}(#{part_inspect(inner)})"
    end    
  end
  
  class Binary
    include PrintSupport
    def inspect
      "#{self.class.shorthand}(#{part_inspect(left)},#{part_inspect(right)})"
    end
  end
  
  module ContainerToString
    def to_s(indent="")
      next_indent = indent + " " + " "
      
      str = "#{indent}#{self.class.shorthand}(\n"
      str << "#{part_to_s(left, next_indent)},\n"
      str << "#{part_to_s(right, next_indent)}\n"
      str << "#{indent})"
      str << "\n" if indent == ""
      
      str
    end
  end
  
  class And; include ContainerToString end
  class Or; include ContainerToString end
  
end