require 'ruby_parser'
require 'ruby2ruby'

module Wrong
  class Chunk
    def self.from_block(block, depth = 0)
      file, line = if block.to_proc.respond_to? :source_location
                     # in Ruby 1.9, it reads the source location from the block
                     block.to_proc.source_location
                   else
                     # in Ruby 1.8, it reads the source location from the call stack
                     caller[depth].split(":")
                   end
      new(file, line)
    end

    attr_reader :file, :line_number

    # line parameter is 1-based
    def initialize(file, line_number)
      @file = file
      @line_number = line_number.to_i
    end

    def line_index
      @line_number - 1
    end

    def location
      "#{@file}:#{@line_number}"
    end

    # Algorithm:
    # try to parse the starting line
    # if it parses OK, then we're done!
    # if not, then glom the next line and try again
    # repeat until it parses or we're out of lines
    def parse
      lines = File.read(@file).split("\n")
      @parser ||= RubyParser.new
      @chunk = nil
      c = 0
      @sexp = nil
      while @sexp.nil? && line_index + c < lines.size
        begin
          @chunk = lines[line_index..line_index+c].join("\n")
          @sexp = @parser.parse(@chunk)
        rescue Racc::ParseError => e
          # loop and try again
          c += 1
        end
      end
      @sexp
    end
    
    # The claim is the part of the assertion inside the curly braces.
    # E.g. for "assert { x == 5 }" the claim is "x == 5"
    def claim
      parse()

      if @sexp.nil?
        raise "Could not parse #{location}"
      else
        assertion = @sexp.assertion
        statement = assertion && assertion[3]
        if statement.nil?
          raise "Could not find assertion in #{location}\n\t#{@chunk.strip}\n\t#{@sexp}"
        else
          statement
        end
      end
    end

    def code
      self.claim.to_ruby
    end

    def parts(sexp = nil)
      if sexp.nil?
        parts(self.claim).compact.uniq
      else
        # todo: extract into Sexp, once I have more unit tests
        parts_list = []
        begin
          code = sexp.to_ruby.strip
          parts_list << code unless code == ""
        rescue => e
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
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

# todo: move to separate monkey patch file
class Sexp < Array
  def doop
    Marshal.load(Marshal.dump(self))
  end

  def to_ruby
    d = self.doop
    x = Ruby2Ruby.new.process(d)
    x
  end

  def assertion?
    self.is_a? Sexp and
      self[0] == :iter and
      self[1].is_a? Sexp and
      self[1][0] == :call and
      [:assert, :deny].include? self[1][2] # todo: allow aliases for assert (e.g. "is")
  end

  def assertion
    sexp = self
    assertion = if sexp.assertion?
                  sexp
                else
                  # todo: extract into sexp
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
