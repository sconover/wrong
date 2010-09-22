

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
