require "predicated/predicate"
require "predicated/evaluate"
require "predicated/string_utils"

module Predicated
  class AutogenCall < Call
    def to_s
      method_cameled = StringUtils.uppercamelize(method_sym.to_s)
      
      if Predicated.const_defined?(:SimpleTemplatedShorthand) && left == Placeholder
        "#{method_cameled}#{right_to_s}"
      else
        left_str = left_to_s
        right_str = right_to_s
        right_str = "," + right_str unless right_str.empty?
        "#{method_cameled}(#{left_str}#{right_str})"
      end
    end
  end
  
  module Shorthand
    def method_missing(uppercase_cameled_method_sym, *args)
      subject = args.shift
      method_sym = StringUtils.underscore(uppercase_cameled_method_sym.to_s).to_sym
      object = args
      AutogenCall.new(subject, method_sym, (object.empty? ? [] : object))
    end
  end

  module SimpleTemplatedShorthand
    def method_missing(uppercase_cameled_method_sym, *args)
      method_sym = StringUtils.underscore(uppercase_cameled_method_sym.to_s).to_sym
      object = args
      AutogenCall.new(Placeholder, method_sym, (object.empty? ? [] : object))
    end
  end
end