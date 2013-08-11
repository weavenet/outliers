module Outliers
  class Resource

    attr_reader :source

    def self.key
      'name'
    end

    def self.verifications
      {}
    end

    def initialize(source)
      @source = source
      @logger = Outliers.logger
    end

    def id
      @source.send self.class.key
    end

    def method_missing(method)
      @source.send method
    end

    private

    def logger
      @logger
    end

  end
end
