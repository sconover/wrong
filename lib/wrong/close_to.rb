# TODO: make it a module, and optionally include it into Float and Fixnum if asked

class Float
  def close_to?(other, tolerance = 0.001)
    (self - other.to_f).abs < tolerance
  end
end

class Fixnum
  def close_to?(*args)
    self.to_f.close_to?(*args)
  end
end
