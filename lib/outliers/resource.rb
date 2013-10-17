module Outliers
  class Resource

    attr_reader :source

    def self.key
      'name'
    end

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Resources']).map { |p| p.underscore }.join('_').downcase
    end

    def self.verifications
      []
    end

    def self.find_by_name(name)
      Outliers::Resources.find_by_name name
    end

    def self.list
      Outliers::Resources.resources
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
