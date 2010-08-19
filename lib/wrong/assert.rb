require "predicated/predicate"
require "predicated/from/callable_object"
require "predicated/to/sentence"
require "wrong/chunk"

#see http://yehudakatz.com/2009/01/18/other-ways-to-wrap-a-method/
class Module
  def overridable(&blk)
    mod = Module.new(&blk)
    include mod
  end
end

module Wrong
  module Assert

    class AssertionFailedError < RuntimeError;
    end

    def failure_class
      AssertionFailedError
    end

    def assert(&block)
      aver(:assert, &block)
    end

    def deny(&block)
      aver(:deny, &block)
    end

    def catch_raise
      error = nil
      begin
        yield
      rescue Exception, RuntimeError => e
        error = e
      end
      error
    end

    overridable do
      def failure_message(method_sym, block, predicate)
        method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
      end
    end

    def self.disable_existing_assert_methods(the_class)
      (the_class.public_instance_methods.
        map { |m| m.to_s }.
        select { |m| m =~ /^assert/ } - ["assert"]).each do |old_assert_method|
        the_class.class_eval(%{
          def #{old_assert_method}(*args)
            raise "#{old_assert_method} has been disabled.  When you use Wrong, it overrides 'assert', which most test frameworks have defined, and use internally."
          end
        })
      end
    end

    private

    def details(block, chunk)
      details = ""
      parts = chunk.parts
      parts.shift # remove the first part, since it's the same as the code
      if parts.size > 1
        details = "\n"
        parts.each do |part|
          if part =~ /\n/m
            part.gsub!(/\n/, "\n    ")
            part += "\n      "
          end
          begin
            value = eval(part, block.binding).inspect
            details << "    #{part} is #{value}\n" unless part == value
          rescue Exception => e
            details << "    #{part} : #{e.class}: #{e.message}\n"
            if false
              puts "#{e.class}: #{e.message} evaluating #{part.inspect}"
              puts "\t" + e.backtrace.join("\n\t")
            end
          end
        end
      end
      details
    end

    def aver(valence, depth = nil, &block)
      value = block.call
      value = !value if valence == :deny
      unless value
        chunk = Wrong::Chunk.from_block(block, depth || 2)
        code = chunk.code
        predicate = Predicated::Predicate.from_ruby_code_string(code, block.binding)
        message = "#{valence == :deny ? "Didn't expect" : "Expected"} #{code}, but #{failure_message(valence, block, predicate)}"
        message << details(block, chunk)
        raise failure_class.new(message)
      end
    end
  end

end
