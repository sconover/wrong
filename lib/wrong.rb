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

module Wrong
  include Wrong::Assert
  extend Wrong::Assert
  include Wrong::Helpers
  extend Wrong::Helpers
end

# this does some magic; if you don't like it, `require 'wrong/assert'` et al. individually and don't `require 'wrong/close_to'` or `require 'wrong'`
require "wrong/close_to"

# this does some magic; if you don't like it, `require 'wrong/assert'` et al. individually, don't `require 'wrong'`, and `include Wrong::D` only in the modules you want to call `d` from
Object.send :include, Wrong::D
