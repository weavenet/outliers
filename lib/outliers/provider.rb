module Outliers
  class Provider

    attr_reader :account

    def self.connect_to(account)
      provider = account.fetch 'provider'
      Outliers::Providers.name_map.fetch(provider).new account
    rescue KeyError
      raise Outliers::Exceptions::UnknownProvider.new "Unkown provider '#{provider.join('_').downcase}'."
    end

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Providers']).map { |p| p.underscore }.join('_').downcase
    end

    def initialize(account)
      @account = account
      @logger      = Outliers.logger
      settings account.keys_to_sym
    end

    def logger
      @logger
    end

  end
end
