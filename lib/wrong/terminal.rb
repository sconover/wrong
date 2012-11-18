module Wrong
  class Terminal

    # Returns [width, height] of terminal when detected, nil if not detected.
    # Think of this as a simpler version of Highline's Highline::SystemExtensions.terminal_size()
    # Lifted from https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb#L59
    #
    # See also http://stackoverflow.com/questions/2068859/how-to-get-the-width-of-terminal-window-in-ruby
    #  https://github.com/genki/ruby-terminfo/blob/master/lib/terminfo.rb
    #  http://www.mkssoftware.com/docs/man1/stty.1.asp

    def self.size
      @@terminal_size ||= begin
        if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
          [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
        elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
          [`tput cols`.to_i, `tput lines`.to_i]
        elsif STDIN.tty? && command_exists?('stty')
          `stty size`.scan(/\d+/).map { |s| s.to_i }.reverse
        else
          nil
        end
      rescue
        nil
      end
    end

    def self.width
      (@terminal_width ||= nil) || (size && size.first) || 80
    end

    def self.width= forced_with
      @terminal_width = forced_with
    end

    # Determines if a shell command exists by searching for it in ENV['PATH'].
    def self.command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? { |d| File.exists? File.join(d, command) }
    end


  end
end
