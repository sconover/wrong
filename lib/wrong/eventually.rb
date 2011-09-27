module Wrong
  module Eventually
    def eventually &block
      raise "please pass a block to the eventually method" if block.nil?
      # def aver(valence, explanation = nil, depth = 0, &block)

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

# module Selenium
#   module WaitFor
#     Context = Struct.new(:message)
#     # Poll continuously for the return value of the block to be true. You can use this to assert that a client side
#     # or server side condition was met.
#     #   wait_for do
#     #     User.count == 5
#     #   end
#     def wait_for(params={})
#       timeout = params[:timeout] || default_wait_for_time
#       message = params[:message] || "Timeout exceeded"
#       configuration = Context.new(message)
#       begin_time = time_class.now
#       while (time_class.now - begin_time) < timeout
#         if value = yield(configuration)
#           return value
#         end
#         return value if value
#         sleep 0.25
#       end
#       flunk(configuration.message + " (after #{timeout} sec)")
#       true
#     end
# 
#     def default_wait_for_time
#       5
#     end
# 
#     def time_class
#       Time
#     end
# 
#     # The default Selenium Core client side timeout.
#     def default_timeout
#       @default_timeout ||= 20000
#     end
#     attr_writer :default_timeout
#   end
# end
