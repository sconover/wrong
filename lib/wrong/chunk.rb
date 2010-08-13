require 'ruby_parser'
require 'ruby2ruby'

module Wrong
  class Chunk
    def self.from_block(block, depth = 0)
      file, line = if block.to_proc.respond_to? :source_location
                     block.to_proc.source_location
                   else
                     caller[depth].split(":")
                   end
      new(file, line)
    end

    def initialize(file, line)
      @file = file
      @line = line.to_i - 1
    end

    def sexp
      lines = File.read(@file).split("\n")
      parser = RubyParser.new
      c = 0
      sexp = nil
      while sexp.nil? && @line + c < lines.size
        begin
          @chunk = lines[@line..@line+c].join("\n")
          sexp = parser.parse(@chunk)
            #      p sexp
        rescue Racc::ParseError => e
          # loop and try again
          c += 1
        end
      end
      sexp
    end

    def code
      @code ||= begin
        sexp = sexp()
        ruby2ruby = Ruby2Ruby.new
        code = ruby2ruby.process(sexp[3])
        puts "chunk: #{@chunk.strip}"
        puts "sexp: #{sexp}"
        puts "code: #{code.strip}"
        code
      end
    end
  end
end
