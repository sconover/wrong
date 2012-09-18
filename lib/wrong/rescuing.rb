module Wrong
  module Rescuing

    # Executes a block that is expected to raise an exception. Returns that exception, or nil if none was raised.
    def rescuing
      error = nil
      begin
        yield
      rescue Exception, RuntimeError => e
        error = e
      end
      error
    end
  end
end
