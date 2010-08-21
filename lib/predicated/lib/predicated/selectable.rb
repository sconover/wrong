
class Object
  # todo: make this definition conditional
  # todo: move this to a monkey patch file
  def singleton_class
     class << self
       self
     end
  end
end

module Predicated
  module Selectable
    # Make an Enumerable instance into a Selectable. 
    # This does for instances what "include Selectable" does for classes.
    # todo: rename?
    def self.bless_enumerable(enumerable, selectors)
      enumerable.singleton_class.instance_eval do
        include Selectable
        selector selectors
      end
    end

    # merge several hashes into one, skipping nils
    # todo: unit test
    # todo: move onto Hash?
    def self.merge_many(*hashes)
      result = {}
      hashes.compact.each do |hash|
        result.merge! hash
      end
      result
    end

    SELECTORS = :@_predicated_selectors

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def selector(hash)
        instance_variable_set(SELECTORS, Selectable.merge_many(instance_variable_get(SELECTORS), hash))
      end
    end

    def selectors
      class_selectors = self.class.instance_variable_get(SELECTORS)
      singleton_selectors = self.singleton_class.instance_variable_get(SELECTORS)
      instance_selectors = self.instance_variable_get(SELECTORS)
      Selectable.merge_many(class_selectors, singleton_selectors, instance_selectors)
    end

    def select(*keys, &block)
      if block_given?
        super
      else
        key = keys.shift
        result =
          if key
            selecting_proc = selectors[key]
            raise "no selector found for '#{key}'.  current selectors: [#{selectors.collect { |k, v| k.to_s }.join(",")}]" unless selecting_proc
            memos_for(:select)[key] ||= begin
              super(&selecting_proc)
            end
          else
            raise "select must be called with either a key or a block"
          end

        Selectable.bless_enumerable(result, selectors)

        if keys.length >= 1
          result.select(*keys, &block)
        else
          result
        end
      end
    end

    private
    def memos_for(group)
      @_predicated_memos ||= {}
      @_predicated_memos[group] ||= {}
    end
  end

  all_basic_selectors = {:all => proc{|predicate, enumerable|true}}.merge(
    ([Unary, Binary, Operation] + ALL_PREDICATE_CLASSES).inject({}) do |h, klass|
      h[klass] = proc{|predicate, enumerable|predicate.is_a?(klass)}
      h
    end
  )
  
  ALL_PREDICATE_CLASSES.each do |klass|
    klass.class_eval do 
      klass.send(:include, Selectable)
      klass.selector all_basic_selectors
    end
  end
end


