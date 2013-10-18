require 'json'

module Outliers
  class Result

    attr_reader :account_name, :arguments, :name, :passing,
                :provider_name, :resources, :resource_name, :verification_name

    def to_json
      to_hash.to_json
    end

    def to_hash
      { 'account_name'      => account_name,
        'arguments'         => arguments,
        'name'              => name,
        'passing'           => passing,
        'provider_name'     => provider_name,
        'resource_name'     => resource_name,
        'verification_name' => verification_name,
        'resources'         => resources }
    end

    def initialize(args)
      @account_name      = args[:account_name]
      @arguments         = args[:arguments]
      @name              = args[:name] || 'unspecified'
      @provider_name     = args[:provider_name]
      @resources         = args[:resources]
      @resource_name     = args[:resource_name]
      @passing           = args[:passing]
      @verification_name = args[:verification_name]
    end

    def passed?
      @passing
    end

    def failed?
      !passed?
    end

  end
end
