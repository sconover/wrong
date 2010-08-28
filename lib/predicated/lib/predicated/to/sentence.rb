require "predicated/predicate"
require "predicated/evaluate"

module Predicated
  
  module Conjunction
    def to_sentence
      left.to_sentence + joining_str + right.to_sentence
    end

    def to_negative_sentence
      "This is not true: " + to_sentence
    end
  end

  class And; include Conjunction; def joining_str; " and " end; end
  class Or; include Conjunction; def joining_str; " or " end;end
  
  class Not
    def to_sentence
      inner.to_negative_sentence
    end

    def to_negative_sentence
      inner.to_sentence
    end
  end
  
  class Operation

    def self.register_verb_phrase(method_sym, 
                                  positive_verb_phrase, 
                                  negative_verb_phrase, 
                                  accepts_object=true)      
      @@method_sym_to_phrase_info[method_sym] = {
        :positive => positive_verb_phrase,
        :negative => negative_verb_phrase,
        :accepts_object => accepts_object
      }
    end
    
    def self.reset_verb_phrases
      @@method_sym_to_phrase_info = {}
      
      register_verb_phrase(:==, "is equal to", "is not equal to")
      register_verb_phrase(:>, "is greater than", "is not greater than")
      register_verb_phrase(:<, "is less than", "is not less than")
      register_verb_phrase(:>=, "is greater than or equal to", "is not greater than or equal to")
      register_verb_phrase(:<=, "is less than or equal to", "is not less than or equal to")

      register_verb_phrase(:include?, "includes", "does not include")
      register_verb_phrase(:is_a?, "is a", "is not a")
      register_verb_phrase(:nil?, "is nil", "is not nil", accepts_object=false)
      
      nil
    end
    
    reset_verb_phrases
    
    
    def to_sentence
      sentence(verb_phrase[:positive])
    end
    
    def to_negative_sentence
      sentence(verb_phrase[:negative])
    end
    
    private 
    
    def sentence(verb_phrase_str)
      left_str = format_value(left)
      right_str = format_value(right)
      
      str = left_str + " " + verb_phrase_str
      str << " " + right_str if verb_phrase[:accepts_object]
      str
    end
          
    def verb_phrase
      @@method_sym_to_phrase_info[method_sym] || {
        :positive => "is " + rudimentary=method_sym.to_s.gsub("_", " ").gsub("?", ""),
        :negative => "is not " + rudimentary,
        :accepts_object => true
      } 
    end
        
    def format_value(value)
      value.inspect
    end

  end
  
end
