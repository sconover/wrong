module Wrong
  module CloseTo
    def close_to?(other, tolerance = 0.001)
      if respond_to? :to_f
        (self.to_f - other.to_f).abs < tolerance
      elsif respond_to? :to_time
        self.to_time.close_to?( other.to_time, tolerance)
      end
    end
  end
  Numeric.send :include, CloseTo
  Date.send :include, CloseTo
  Time.send :include, CloseTo
end
