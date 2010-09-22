module Wrong
  def self.config
    @config ||= Config.new
  end

  class Config < Hash
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
