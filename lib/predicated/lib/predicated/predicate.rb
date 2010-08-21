require "predicated/gem_check"

module Predicated

  def Predicate(&block)
    result = nil
    Module.new do
      extend Shorthand
      result = instance_eval(&block)
    end
    result
  end
  
  class Predicate; end #marker class
  
  class Unary < Predicate
    attr_accessor :inner
    
    def initialize(inner)
      @inner = inner
    end    
    
    module FlipThroughMe
      def each(ancestors=[], &block)
        yield([self, ancestors])
        ancestors_including_me = ancestors.dup + [self]
        inner.each(ancestors_including_me) { |item| block.call(item) } if inner.is_a?(Enumerable)
      end
    end
    include FlipThroughMe
    include Enumerable
    
    module ValueEquality
      def ==(other)
        self.class == other.class && 
        self.inner == other.inner
      end
    end
    include ValueEquality
  end
  
  class Binary < Predicate
    attr_accessor :left, :right
    
    def initialize(left, right)
      @left = left
      @right = right
    end    
    
    module FlipThroughMe
      def each(ancestors=[], &block)
        yield([self, ancestors])
        ancestors_including_me = ancestors.dup + [self]
        enumerate_side(@left, ancestors_including_me, &block)
        enumerate_side(@right, ancestors_including_me, &block)
      end
      
      private 
      def enumerate_side(thing, ancestors)
        thing.each(ancestors) { |item| yield(item) } if thing.is_a?(Enumerable)
      end
    end
    include FlipThroughMe
    include Enumerable
    
    module ValueEquality
      def ==(other)
        self.class == other.class && 
        self.left == other.left && 
        self.right == other.right
      end
    end
    include ValueEquality
  end
  
  
  
  
  class And < Binary; def self.shorthand; :And end end
  class Or < Binary; def self.shorthand; :Or end end
  class Not < Unary; def self.shorthand; :Not end end

  
  class Operation < Binary; end
  
  class Equal < Operation; def self.shorthand; :Eq end end
  class LessThan < Operation; def self.shorthand; :Lt end end
  class GreaterThan < Operation; def self.shorthand; :Gt end end
  class GreaterThanOrEqualTo < Operation; def self.shorthand; :Gte end end
  class LessThanOrEqualTo < Operation; def self.shorthand; :Lte end end
  
  
  module Shorthand
    def And(left, right) ::Predicated::And.new(left, right) end
    def Or(left, right) ::Predicated::Or.new(left, right) end
    def Not(inner) ::Predicated::Not.new(inner) end

    def Eq(left, right) ::Predicated::Equal.new(left, right) end
    def Lt(left, right) ::Predicated::LessThan.new(left, right) end
    def Gt(left, right) ::Predicated::GreaterThan.new(left, right) end
    def Lte(left, right) ::Predicated::LessThanOrEqualTo.new(left, right) end
    def Gte(left, right) ::Predicated::GreaterThanOrEqualTo.new(left, right) end    
  end
  
  ALL_PREDICATE_CLASSES = [
    And, Or, Not, 
    Equal, LessThan, GreaterThan, LessThanOrEqualTo, GreaterThanOrEqualTo
  ]
end

require "predicated/print"
