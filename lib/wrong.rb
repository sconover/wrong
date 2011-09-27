dir = File.expand_path(File.dirname(__FILE__))
$: << dir unless $:.include?(dir) # should we really have to do this? It's necessary to run examples.rb

require "predicated"
require "wrong/assert"
require "wrong/helpers"
require "wrong/chunk"
require "wrong/sexp_ext"
require "wrong/version"
require "wrong/config"
require "wrong/irb"
require "wrong/d"
require "wrong/message/array_diff"
require "wrong/message/string_comparison"
require "wrong/eventually"

module Wrong
  include Wrong::Assert
  extend Wrong::Assert
  include Wrong::Helpers
  extend Wrong::Helpers
  include Wrong::Eventually
  extend Wrong::Eventually
end

# this does some magic; if you don't like it...

# ...`require 'wrong/assert'` et al. individually and don't `require 'wrong/close_to'` or `require 'wrong'`
require "wrong/close_to"

# ...don't `require 'wrong'`, and `include Wrong::D` only in the modules you want to call `d` from
class Object  # should we add this to Kernel instead?
  include Wrong::D
end

# ...don't `require 'wrong'`
# this part isn't working yet -- it's supposed to make 'assert' available at the top level but it breaks the minitest adapter
# include Wrong
# class Object
#   include Wrong
# end
