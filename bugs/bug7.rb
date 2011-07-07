here = File.dirname(__FILE__)
$:<<"#{here}/../lib"

require 'rubygems'
# gem "test-unit"  # uncomment for this to work

gem "predicated"
require 'test/unit'
require 'wrong/adapters/test_unit'

class WrongTest < Test::Unit::TestCase
 include Wrong

 def test_something
   puts 'tested something'
   assert { true }
 end
end
