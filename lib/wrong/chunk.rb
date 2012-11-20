require 'ruby_parser'
require 'ruby2ruby'
require 'pp'

require "wrong/config"
require "wrong/sexp_ext"
require "wrong/capturing"

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
                relevant_caller = caller[depth]
                relevant_caller.split(":")
              end

      new(file, line, &block)
    end

    include Capturing

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
      glom(if @file == "(irb)"
             IRB.CurrentContext.all_lines
           else
             read_source_file(@file)
           end)
    end

    def read_source_file(file)
      Config.read_here_or_higher(file)
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
          capturing(:stderr) do  # new RubyParser is too loud
            sexp = @parser.parse(@chunk)
          end
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

  end

end
