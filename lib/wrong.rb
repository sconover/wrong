dir = File.expand_path(File.dirname(__FILE__))
$: << dir unless $:.include?(dir) # should we really have to do this? It's necessary to run examples.rb

require "predicated"
require "wrong/assert"
require "wrong/chunk"
require "wrong/sexp_ext"
require "wrong/version"
require "wrong/config"
require "wrong/irb"
