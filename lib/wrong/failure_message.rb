require "wrong/chunk"
require "wrong/terminal"

module Wrong
  class FailureMessage
    @@formatters = []

    def self.register_formatter(formatter)
      @@formatters << formatter
    end

    def self.formatters
      @@formatters
    end

    def self.formatter_for(predicate)
      @@formatters.each do |formatter_class|
        formatter = formatter_class.new(predicate)
        if formatter.match?
          return formatter
        end
      end
      nil
    end

    class Formatter
      def self.register
        Wrong::FailureMessage.register_formatter(self)
      end

      attr_reader :predicate

      def initialize(predicate)
        @predicate = predicate
      end

      def describe(valence)

      end

      def match?
        false
      end
    end

    attr_accessor :chunk, :valence, :explanation

    def initialize(chunk, valence, explanation)
      @chunk, @valence, @explanation = chunk, valence, explanation
    end

    def basic
      "#{valence == :deny ? "Didn't expect" : "Expected"} #{colored(:blue, chunk.code)}"
    end

    def full
      message = ""
      message << "#{explanation}: " if explanation
      message << basic

      formatted_message = if predicate && !(predicate.is_a? Predicated::Conjunction)
                            if formatter = FailureMessage.formatter_for(predicate)
                              colored(:bold, formatter.describe)
                            end
                          end

      unless details.empty? and formatted_message.nil?
        message << ", but"
      end

      message << formatted_message if formatted_message
      message << details unless details.empty?
      message
    end

    def details
      @details ||= begin
        require "wrong/rainbow" if Wrong.config[:color]
        s = ""
        parts = chunk.parts

        parts.shift while parts.first == "()" # the parser adds this sometimes
        parts.shift # remove the first part, since it's the same as the code

        details = []

        if parts.size > 0
          parts.each do |part|
            begin
              value = eval(part, chunk.block.binding)
              unless part == value.inspect # this skips literals or tautologies
                if part =~ /\n/m
                  part.gsub!(/\n/, newline(2))
                  part += newline(3)
                end
                value = pretty_value(value, (4 + part.length + 4))
                if Wrong.config[:color]
                  part = part.color(:blue)
                  value = value.color(:magenta)
                end
                details << indent(4, part, " is ", value)
              end
            rescue Exception => e
              raises = "raises #{e.class}"
              if Wrong.config[:color]
                part = part.color(:blue)
                raises = raises.bold.color(:red)
              end
              formatted_exeption = if e.message and e.message != e.class.to_s
                                     indent(4, part, " ", raises, ": ", indent_all(6, e.message))
                                   else
                                     indent(4, part, " ", raises)
                                   end
              details << formatted_exeption
            end
          end
        end

        details.uniq!
        if details.empty?
          ""
        else
          "\n" + details.join("\n") + "\n"
        end
      end

    end

    # todo: use awesome_print
    def pretty_value(value, starting_col = 0, indent_wrapped_lines = 6, width = Terminal.width)
      # inspected = value.inspect

      # note that if the first line overflows due to the starting column then pp won't wrap it right
      inspected = PP.pp(value, "", width - starting_col).chomp

      # this bit might be redundant with the pp call now
      indented = indent_all(6, inspected)
      if width
        wrap_and_indent(indented, starting_col, indent_wrapped_lines, width)
      else
        indented
      end
    end

    protected
    def code
      @code ||= chunk.code
    end

    def predicate
      @predicate ||= begin
        Predicated::Predicate.from_ruby_code_string(code, chunk.block.binding)
      rescue Predicated::Predicate::DontKnowWhatToDoWithThisSexpError, Exception => e
        # save it off for debugging
        @@last_predicated_error = e
        nil
      end
    end

    def colored(color, text)
      if Wrong.config[:color]
        if color == :bold
          text.bold
        else
          text.color(color)
        end
      else
        text
      end
    end

    def indent(indent, *s)
      "#{" " * indent}#{s.join('')}"
    end

    def newline(indent)
      "\n" + self.indent(indent)
    end

    def indent_all(amount, s)
      s.gsub("\n", "\n#{indent(amount)}")
    end

    def wrap_and_indent(indented, starting_col, indent_wrapped_lines, full_width)
      first_line = true
      width = full_width - starting_col # the first line is essentially shorter
      indented.split("\n").map do |line|
        s = ""
        while line.length > width
          s << line[0...width]
          s << newline(indent_wrapped_lines)
          line = line[width..-1]
          if first_line
            width += starting_col - indent_wrapped_lines
            first_line = false
          end
        end
        s << line
        s
      end.join("\n")
    end

  end
end
