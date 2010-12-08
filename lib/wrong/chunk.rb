require 'ruby_parser'
require 'ruby2ruby'
require 'pp'

def require_optionally(library)
  begin
    require library
  rescue LoadError => e
    raise e unless e.message == "no such file to load -- #{library}"
  end
end

require_optionally "ParseTree"
require_optionally "sourcify"

require "wrong/config"
require "wrong/sexp_ext"

module Wrong
  class Chunk
    def self.from_block(block, depth = 0)

      as_proc = block.to_proc
      file, line =
              if as_proc.respond_to? :source_location
                # in Ruby 1.9, or with Sourcify, it reads the source location from the block
                as_proc.source_location
              else
                # in Ruby 1.8, it reads the source location from the call stack
                # # $stderr.puts "---"
                # $stderr.puts caller.join("\n")
                relevant_caller = caller[depth]
                # $stderr.puts "*** #{relevant_caller}"
                relevant_caller.split(":")
              end

      new(file, line, &block)
    end

    attr_reader :file, :line_number, :block

    # line parameter is 1-based
    def initialize(file, line_number, &block)
      @file = file
      @line_number = line_number.to_i
      @block = block
    end

    def line_index
      @line_number - 1
    end

    def location
      "#{@file}:#{@line_number}"
    end

    def sexp
      @sexp ||= build_sexp
    end

    def build_sexp
      sexp = begin
        unless @block.nil? or @block.is_a?(String) or !Object.const_defined?(:Sourcify)
          # first try sourcify
          @block.to_sexp[3] # the [3] is to strip out the "proc {" sourcify adds to everything
        end
      rescue Exception => e
        # sourcify failed, so fall through
      end

      # next try glomming
      sexp ||= glom(if @file == "(irb)"
                      IRB.CurrentContext.all_lines
                    else
                      read_source_file(@file)
                    end)
    end

    def read_source_file(file)
      Chunk.read_here_or_higher(file)
    end

    def self.read_here_or_higher(file, dir = ".")
      File.read "#{dir}/#{file}"
    rescue Errno::ENOENT, Errno::EACCES => e
      # we may be in a chdir underneath where the file is, so move up one level and try again
      parent = "#{dir}/..".gsub(/^(\.\/)*/, '')
      if File.expand_path(dir) == File.expand_path(parent)
        raise Errno::ENOENT, "couldn't find #{file}"
      end
      read_here_or_higher(file, parent)
    end

    # Algorithm:
    # * try to parse the starting line
    # * if it parses OK, then we're done!
    # * if not, then glom the next line and try again
    # * repeat until it parses or we're out of lines
    def glom(source)
      lines = source.split("\n")
      @parser ||= RubyParser.new
      @chunk = nil
      c = 0
      sexp = nil
      while sexp.nil? && line_index + c < lines.size
        begin
          @chunk = lines[line_index..line_index+c].join("\n")
          sexp = @parser.parse(@chunk)
        rescue Racc::ParseError => e
          # loop and try again
          c += 1
        end
      end
      sexp
    end

    # The claim is the part of the assertion inside the curly braces.
    # E.g. for "assert { x == 5 }" the claim is "x == 5"
    def claim
      sexp()

      if @sexp.nil?
        raise "Could not parse #{location}"
      else
        assertion = @sexp.assertion
        statement = assertion && assertion[3]
        if statement.nil?
          @sexp
#          raise "Could not find assertion in #{location}\n\t#{@chunk.strip}\n\t#{@sexp}"
        else
          statement
        end
      end
    end

    def code
      self.claim.to_ruby
    rescue => e
      # note: this is untested; it's to recover from when we can't locate the code
      message = "Failed at #{file}:#{line_number} [couldn't retrieve source code due to #{e.inspect}]"
      raise message
    end

    def parts(sexp = nil)
      if sexp.nil?
        parts(self.claim).compact.uniq
      else
        # todo: extract some of this into Sexp
        parts_list = []
        begin
          unless [:arglist, :lasgn, :iter].include? sexp.first
            code = sexp.to_ruby.strip
            parts_list << code unless code == "" || parts_list.include?(code)
          end
        rescue => e
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
        end

        if sexp.first == :iter
          sexp.delete_at(1) # remove the method-call-sans-block subnode
        end

        sexp.each do |sub|
          if sub.is_a?(Sexp)
            parts_list += parts(sub)
          end
        end

        parts_list
      end
    end

    def details
      @details ||= build_details
    end
    
    def pretty_value(value, starting_col = 0, indent_wrapped_lines = 6, width = Chunk.terminal_width)
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

    private

    # todo: move to FailureMessage?
    def build_details
      require "wrong/rainbow" if Wrong.config[:color]
      s = ""
      parts = self.parts
      parts.shift # remove the first part, since it's the same as the code

      details = []

      if parts.size > 0
        parts.each do |part|
          begin
            value = eval(part, block.binding)
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

public # don't know exactly why this needs to be public but eval'ed code can't find it otherwise
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

    # Returns [width, height] of terminal when detected, nil if not detected.
    # Think of this as a simpler version of Highline's Highline::SystemExtensions.terminal_size()
    # Lifted from https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb#L59
    def self.terminal_size
      @@terminal_size ||= begin
        if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
          [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
        elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
          [`tput cols`.to_i, `tput lines`.to_i]
        elsif STDIN.tty? && command_exists?('stty')
          `stty size`.scan(/\d+/).map { |s| s.to_i }.reverse
        else
          nil
        end
      rescue
        nil
      end  
    end
    
    def self.terminal_width
      terminal_size && terminal_size.first
    end
    
    # Determines if a shell command exists by searching for it in ENV['PATH'].
    def self.command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end
    

  end

end
