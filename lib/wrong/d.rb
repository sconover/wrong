require "sexp"
require "wrong/chunk"
require "pp"

class ::Sexp < ::Array
  def d?
    is_a?(Sexp) &&
            (self[0] == :iter) &&
            (self[1][0] == :call) &&
            (self[1][2] == :d)
  end

end

module Wrong
  module D
    def d(*args, &block)
      called_from = caller.first.split(':')
      chunk = Chunk.from_block(block, 1)
      sexp = chunk.sexp

      # look for a "d" inside the block
      sexp.each_subexp do |subexp|
        if subexp.d?
          sexp = subexp[3] # swap in the block part of the nested d call
        end
      end

      code = sexp.to_ruby
      value = eval(code, block.binding, called_from[0], called_from[1].to_i)
      width = Chunk.terminal_width
      value = PP.pp(value, "", width - (code.size + 3)).chomp

      if Wrong.config[:color]
        require "wrong/rainbow"
        code = code.color(:blue)
        value = value.color(:magenta)
      end

      puts [code, "is", value].join(" ")
    end

    extend D # this allows you to call Wrong::D.d if you like
  end
end
