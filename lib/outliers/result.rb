require 'json'

module Outliers
  class Result

    attr_reader :account_name, :failing_resources, :name, :passing_resources,
                :provider_name, :resource_name, :verification_name

    def to_json
      { 'account_name'     => account_name,
        'name'                 => name,
        'provider_name'        => provider_name,
        'resource_name'        => resource_name,
        'verification_name'    => verification_name,
        'resources'            => resources }.to_json
    end

    def initialize(args)
      @account_name  = args[:account_name]
      @failing_resources = args[:failing_resources]
      @name              = args[:name] || 'unspecified'
      @passing_resources = args[:passing_resources]
      @provider_name     = args[:provider_name]
      @resource_name     = args[:resource_name]
      @verification_name = args[:verification_name]
    end

    def passed?
      !failed?
    end

    def failed?
      @failing_resources.any?
    end

    private

    def resources
      r = passing_resources.map{|r| { 'id' => r.id, 'passing' => 1 } }
      r += failing_resources.map{|r| { 'id' => r.id, 'passing' => 0 } }
      r
    end

  end
end
