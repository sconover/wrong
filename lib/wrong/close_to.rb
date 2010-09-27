module Wrong
  module CloseTo
    def close_to?(other, tolerance = 0.001)
      (self.to_f - other.to_f).abs < tolerance
    end
  end
  Float.send :include, CloseTo
  Fixnum.send :include, CloseTo
end
