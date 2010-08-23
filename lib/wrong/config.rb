module Wrong
  def self.config
    @config ||= Config.new
  end

  class Config < Hash
  end
end
