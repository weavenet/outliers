module Outliers
  class Provider

    attr_reader :account

    def self.find_by_name(name)
      Outliers::Providers.name_map.fetch name, nil
    end

    def self.connect_to(account)
      provider = account.fetch 'provider'
      Outliers::Providers.name_map.fetch(provider).new account
    rescue KeyError
      raise Outliers::Exceptions::UnknownProvider.new "Unkown provider '#{provider.join('_').downcase}'."
    end

    def self.to_human
      (self.to_s.split('::') - ['Outliers', 'Providers']).map { |p| p.underscore }.join('_').downcase
    end

    def self.resources
      Outliers::Resources.resources.select {|r| r.to_human =~ /^#{to_human}/}
    end

    def self.collections
      Outliers::Resources.collections.select {|r| r.to_human =~ /^#{to_human}/}
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
