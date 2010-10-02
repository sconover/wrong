module Wrong
  module Assert
    # todo: integrate with / use Chunk somehow?
    #
    def failure_message(method_sym, block, predicate)
      upper_portion = super
      
      first_test_line = caller.find{|line|line =~ /(_test.rb|_spec.rb)/}
      raise "Can't find test or spec in call chain: #{caller.join('|')}" if first_test_line.nil?
      file, failure_line_number = first_test_line.split(":",2)
    
      lines = File.readlines(file)
      line_number = failure_line_number.to_i - 1
      to_show = []
      begin
        line = lines[line_number]
        to_show.unshift(line)
        line_number -= 1
      end while !(line =~ /^\s+(test|it)[ ]+/ || line =~ /^\s+def test_\w+/)
    
      to_show[to_show.length-1] = to_show[to_show.length-1].chomp + 
        "      ASSERTION FAILURE #{file}:#{failure_line_number.to_i}\n"
      
      upper_portion + "\n\n" + to_show.join
    end
    
  end
end
