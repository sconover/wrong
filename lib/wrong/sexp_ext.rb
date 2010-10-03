require 'ruby_parser'
require 'ruby2ruby'
require 'wrong/config'

class Sexp < Array

  def to_ruby
    d = self.deep_clone
    ruby = Ruby2Ruby.new.process(d)
    ruby
  end

  # visit every node in the tree, including the root, that is an Sexp
  # todo: test
  def each_subexp(&block)
    yield self
    each do |child|
      if child.is_a?(Sexp)
        child.each_subexp(&block)
      end
    end
  end

  def assertion?
    self.is_a? Sexp and
      self[0] == :iter and
      self[1].is_a? Sexp and
      self[1][0] == :call and
      Wrong.config.assert_methods.include? self[1][2] # todo: allow aliases for assert (e.g. "is")
  end

  def assertion
    sexp = self
    assertion = if sexp.assertion?
                  sexp
                else
                  nested_assertions.first
                end
    assertion
  end

  private
  def nested_assertions
    assertions = []
    self.each_of_type(:iter) { |sexp| assertions << sexp if sexp.assertion? }
    assertions
  end

end
