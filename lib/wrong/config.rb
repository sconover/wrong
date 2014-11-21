
module Wrong

  def self.load_config
    settings = begin
      Config.read_here_or_higher(".wrong")
    rescue Errno::ENOENT
      # couldn't find it
      nil # In Ruby 1.8, "e" would be returned here otherwise
    end
    Config.new settings
  end

  def self.config
    @config ||= load_config
  end

  def self.config=(new_config)
    @config = load_config
  end

  class Config < Hash

    class ConfigError < RuntimeError
    end

    def self.read_here_or_higher(file, dir = ".")
      File.read "#{dir}/#{file}"
    rescue Errno::ENOENT, Errno::EACCES
      # we may be in a chdir underneath where the file is, so move up one level and try again
      parent = "#{dir}/..".gsub(/^(\.\/)*/, '')
      if File.expand_path(dir) == File.expand_path(parent)
        raise Errno::ENOENT, "couldn't find #{file}"
      end
      read_here_or_higher(file, parent)
    end

    def initialize(string = nil)
      self[:aliases] = {:assert => [:assert], :deny => [:deny]}
      if string
        instance_eval string.gsub(/^(.*=)/, "self.\\1")
      end
    end

    def method_missing(name, value = true)
      name = name.to_s
      if name =~ /=$/
        name.gsub!(/=$/, '')
      end
      self[name.to_sym] = value
    end

    def alias_assert_or_deny(valence, extra_name, options)
      Wrong::Assert.send(:alias_method, extra_name, valence)
      new_method_name = extra_name.to_sym
      self[:aliases][valence] << new_method_name unless self[:aliases][valence].include?(new_method_name)
    end

    def alias_assert(method_name, options = {})
      alias_assert_or_deny(:assert, method_name, options)
    end

    def alias_deny(method_name, options = {})
      alias_assert_or_deny(:deny, method_name, options)
    end

    def assert_method_names
      self[:aliases][:assert]
    end

    def deny_method_names
      self[:aliases][:deny]
    end

    def hidden_methods
      assert_method_names + deny_method_names + [:eventually]
    end
  end
end
