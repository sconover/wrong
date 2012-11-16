require 'ruby_parser'
require 'ruby2ruby'
require 'wrong/config'

class Sexp < Array

  def to_ruby
    sexp = self.deep_clone
    ruby = Ruby2Ruby.new.process(sexp)
    ruby
  end

  # visit every node in the tree, including the root, that is an Sexp
  # todo: test
  # todo: use deep_each instead
  def each_subexp(include_root = true, &block)
    yield self if include_root
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
      Wrong.config.hidden_methods.include? self[1][2]
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
    self.each_subexp(false) { |sexp| assertions << sexp if sexp.assertion? }
    assertions
  end

end
