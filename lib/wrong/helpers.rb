require "wrong/capturing"
require "wrong/rescuing"
require "wrong/d"
require "wrong/eventually"
require "wrong/close_to"

module Wrong
  module Helpers
    include Rescuing
    include Capturing
    include Eventually
    include CloseTo
    include D
  end
end
