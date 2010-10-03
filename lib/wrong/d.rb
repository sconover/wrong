require "wrong/chunk"

module Wrong
  module D
    def d(*args, &block)
      chunk = Chunk.from_block(block, 1)
      sexp = chunk.sexp
      # look for a "d" inside the block
      sexp.each_of_type(:iter) do |subexp|
        if subexp[1][0] == :call and
          subexp[1][2] == :d
          sexp = subexp[3] # swap in the block part of the nested d call
        end
      end
      code = sexp.to_ruby
      value = eval(code, block.binding).inspect

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
