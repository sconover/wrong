module Wrong
  module Eventually
    def eventually &block
      raise "please pass a block to the eventually method" if block.nil?
      last_error = nil
      success = nil
      begin_time = Time.now      
      while (Time.now - begin_time) < 5
        begin
          aver(:assert, &block)
          return
        rescue Exception => e
          last_error = e
          sleep 0.25
        end
      end
      raise last_error
    end
  end
end
