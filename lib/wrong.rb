dir = File.expand_path(File.dirname(__FILE__))
$: << dir unless $:.include?(dir) # should we really have to do this? It's necessary to run examples.rb

require "predicated"
require "wrong/assert"
require "wrong/helpers"
require "wrong/chunk"
require "wrong/terminal"
require "wrong/sexp_ext"
require "wrong/version"
require "wrong/config"
require "wrong/irb"
require "wrong/d"
require "wrong/message/array_diff"
require "wrong/message/string_comparison"
require "wrong/eventually"

# After doing "require 'wrong'",
# if you `include Wrong` you will get all of Wrong's asserts and helpers,
# available from both instance and class methods of the object you included it in.
#
# If you only want some of them, then don't "require 'wrong'", and instead
# `require` and `include` just what you want separately.
#
# For example, if you only want `eventually`, then do
#     require "wrong/eventually"
#     include Wrong::Eventually
#
module Wrong
  include Wrong::Assert
  extend Wrong::Assert
  include Wrong::Helpers
  extend Wrong::Helpers
end

# This `require "wrong/close_to"` adds close_to? to Numeric, Date, Time, and DateTime.
# If you don't like that, then
# `require 'wrong/assert'` et al. individually and don't `require 'wrong/close_to'` or `require 'wrong'`
require "wrong/close_to"

# This makes the `d` method available everywhere.
# If you don't like that, then
# don't `require 'wrong'`, and `include Wrong::D` only in the modules you want to call `d` from
class Object  # should we add this to Kernel instead?
  include Wrong::D
end

# this part isn't working yet -- it's supposed to make 'assert' available at the top level but it breaks the minitest adapter
# include Wrong
# class Object
#   include Wrong
# end
