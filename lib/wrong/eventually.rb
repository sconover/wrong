module Wrong
  module Eventually
    NO_BLOCK_PASSED = "you must pass a block to the eventually method"
    
    def eventually options = {}, &block
      raise NO_BLOCK_PASSED if block.nil?
      timeout = options[:timeout] || 5
      delay = options[:delay] || 0.25
      last_error = nil
      success = nil
      begin_time = Time.now      
      while (Time.now - begin_time) < timeout
        begin
          aver(:assert, &block)
          return
        rescue Exception => e
          last_error = e
          sleep delay
        end
      end
      raise last_error
    end
  end
end
