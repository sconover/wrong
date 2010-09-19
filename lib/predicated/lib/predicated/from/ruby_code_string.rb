require "predicated/predicate"
require "predicated/evaluate"

module Predicated

  require_gem_version("ruby_parser", "2.0.4")
  require_gem_version("ruby2ruby", "1.2.4")
  require "predicated/sexp_patch"

  class Predicate
    def self.from_ruby_code_string(ruby_predicate_string, context=binding())
      sexp = RubyParser.new.process(ruby_predicate_string.strip)
      SexpToPredicate.new(context).convert(sexp)
    end
    
    class SexpToPredicate
      SIGN_TO_PREDICATE_CLASS = {
        :== => Equal,
        :> => GreaterThan,
        :< => LessThan,
        :>= => GreaterThanOrEqualTo,
        :<= => LessThanOrEqualTo,
      }
      
      def initialize(context)
        @context = context
      end
      
      def convert(sexp)
        first_element = sexp.first
        if first_element == :block
          #eval all the top lines and then treat the last one as a predicate
          body_sexps = sexp.sexp_body.to_a
          body_sexps.slice(0..-2).each do |upper_sexp|
            eval_sexp(upper_sexp)
          end
          convert(body_sexps.last)
        elsif first_element == :call
          sym, left_sexp, method_sym, right_sexp = sexp
          left = eval_sexp(left_sexp)
          right = eval_sexp(right_sexp)

          if operation_class=SIGN_TO_PREDICATE_CLASS[method_sym]
            operation_class.new(left, right)
          else
            Call.new(left, method_sym, right)
          end
        elsif first_element == :and
          sym, left, right = sexp
          And.new(convert(left), convert(right))
        elsif first_element == :or
          sym, left, right = sexp
          Or.new(convert(left), convert(right))
        elsif first_element == :not
          sym, inner = sexp
          Not.new(convert(inner))
        else
          raise DontKnowWhatToDoWithThisSexpError.new(sexp)
        end
      end
    
      def eval_sexp(sexp)
        eval(Ruby2Ruby.new.process(sexp), @context)
      end
    end
    
    
    class DontKnowWhatToDoWithThisSexpError < StandardError
      def initialize(sexp)
        super("don't know what to do with #{sexp.inspect}")
      end
    end
  end
end