require "predicated/predicate"
require "predicated/from/ruby_code_string"


#raise %{
#
#This will never work in ruby 1.9.
#
#see http://blog.zenspider.com/2009/04/parsetree-eol.html
#
#} if RUBY_VERSION =~/^1.9/

raise %{
  
You appear to be using ruby 1.8.7 and you don't have 
an INLINEDIR environment variable set to a valid directory.

ParseTree (used by "from_callable_object") uses RubyInline.
RubyInline requires that the INLINEDIR environment variable point
to a directory.  The easiest thing to do is to just go
create a directory somewhere - let's say, ~/inlinedir,
and point the INLINEDIR at it.  In bash this would be:

mkdir ~/inlinedir
export INLINEDIR=~/inlinedir

You'll probably want to put this in .bash_profile too.

Sorry for the inconvenience.  I hope the value you'll
get out of "from_callable_object" makes it all worth it.

} if RUBY_VERSION=="1.8.7" && !ENV["INLINEDIR"]
#Procs and lambdas are "callable objects"

module Predicated
  
  require_gem_version("ParseTree", "3.0.5", "parse_tree") if RUBY_VERSION < "1.9"
  
  class Predicate

                                  #hrm
    def self.from_callable_object(context_or_callable_object=nil, context=nil, &block)
      callable_object = nil
      
      if context_or_callable_object.is_a?(Binding) || context_or_callable_object.nil?
        context = context_or_callable_object
        callable_object = block
      else
        callable_object = context_or_callable_object
      end
      
      context ||= callable_object.binding
      
      from_ruby_code_string(TranslateToRubyString.convert(callable_object), context)
    end

    module TranslateToRubyString
      #see http://stackoverflow.com/questions/199603/how-do-you-stringize-serialize-ruby-code
      def self.convert(callable_object)
        temp_class = Class.new
        temp_class.class_eval do
          define_method :serializable, &callable_object
        end
        ruby_code_string = Ruby2Ruby.translate(temp_class, :serializable)    
        ruby_code_string.sub(/^def serializable\n  /, "").sub(/\nend$/, "")
      end
    end
    
    #see http://gist.github.com/321038
    # # Monkey-patch to have Ruby2Ruby#translate with r2r >= 1.2.3, from
    # # http://seattlerb.rubyforge.org/svn/ruby2ruby/1.2.2/lib/ruby2ruby.rb
    class ::Ruby2Ruby < ::SexpProcessor
      def self.translate(klass_or_str, method = nil)
        sexp = ParseTree.translate(klass_or_str, method)
        unifier = Unifier.new
        unifier.processors.each do |p|
          p.unsupported.delete :cfunc # HACK
        end
        sexp = unifier.process(sexp)
        self.new.process(sexp)
      end
      
      #sconover - 7/2010 - monkey-patch
      #{1=>2}=={1=>2}
      #The right side was having its braces cut off because of 
      #special handling of hashes within arglists within the seattlerb code.
      #I tried to fork r2r and add a test, but a lot of other tests
      #broke, and I just dont understand the test in ruby2ruby.
      #So I'm emailing the author...
      def process_hash(exp)
        result = []
        until exp.empty?
          lhs = process(exp.shift)
          rhs = exp.shift
          t = rhs.first
          rhs = process rhs
          rhs = "(#{rhs})" unless [:lit, :str].include? t # TODO: verify better!

          result << "#{lhs} => #{rhs}"
        end

        return "{ #{result.join(', ')} }"
      end

    end
    
  end
end
