module Outliers
  class Provider

    attr_reader :credentials

    def self.connect_to(credentials)
      provider = credentials.fetch 'provider'
      Outliers::Providers.name_map.fetch(provider).new credentials
    rescue KeyError
      raise Outliers::Exceptions::UnknownProvider.new "Unkown provider '#{provider.join('_').downcase}'."
    end

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Providers']).map { |p| p.underscore }.join('_').downcase
    end

    def initialize(credentials)
      @credentials = credentials
      @logger      = Outliers.logger
      settings credentials.keys_to_sym
    end

    def logger
      @logger
    end

  end
end
