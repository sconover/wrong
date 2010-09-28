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

module Wrong
  include Wrong::Assert
  extend Wrong::Assert
  include Wrong::Helpers
  extend Wrong::Helpers

  def self.included(into_class)
    require "wrong/close_to"
  end
end
