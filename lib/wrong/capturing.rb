module Wrong
  module Capturing

    # Usage:
    # capturing { puts "hi" } => "hi\n"
    # capturing(:stderr) { $stderr.puts "hi" } => "hi\n"
    # out, err = capturing(:stdout, :stderr) { ... }
    #
    # see http://www.justskins.com/forums/closing-stderr-105096.html for more explanation
    def capturing(*streams)
      streams = [:stdout] if streams.empty?
      original = {}
      captured = {}

      # reassign the $ variable (which is used by well-behaved code e.g. puts)
      streams.each do |stream|
        original[stream] = (stream == :stdout ? $stdout : $stderr)
        captured[stream] = StringIO.new
        reassign_stream(stream, captured)
      end

      yield

      # return either one string, or an array of two strings
      if streams.size == 1
        captured[streams.first].string
      else
        [captured[streams[0]].string, captured[streams[1]].string]
      end

    ensure

      streams.each do |stream|
        # bail if stream was reassigned inside the block
        if (stream == :stdout ? $stdout : $stderr) != captured[stream]
          raise "#{stream} was reassigned while being captured"
        end
        # support nested calls to capturing
        original[stream] << captured[stream].string if original[stream].is_a? StringIO
        reassign_stream(stream, original)
      end
    end

    private
    def reassign_stream(which, streams)
      case which
        when :stdout
          $stdout = streams[which]
        when :stderr
          $stderr = streams[which]
      end
    end

  end

end
