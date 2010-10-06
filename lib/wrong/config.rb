require "wrong/chunk"

module Wrong
  def self.load_config
    settings = begin
      Chunk.read_here_or_higher(".wrong")
    rescue Errno::ENOENT => e
      # couldn't find it
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
    def initialize(string = nil)
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

    def alias_assert(method_name)
      Wrong::Assert.send(:alias_method, method_name, :assert)
      self.assert_method_names << method_name.to_sym unless self.assert_method_names.include?(method_name)
    end

    def alias_deny(method_name)
      Wrong::Assert.send(:alias_method, method_name, :deny)
      self.deny_method_names << method_name.to_sym unless self.deny_method_names.include?(method_name)
    end

    def assert_method_names
      (self[:assert_method] ||= [:assert])
    end

    def deny_method_names
      (self[:deny_method] ||= [:deny])
    end

    def assert_methods
      assert_method_names + deny_method_names
    end
  end
end
