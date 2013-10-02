require 'json'

module Outliers
  class Result

    attr_reader :credentials_name, :failing_resources, :name, :passing_resources,
                :provider_name, :resource_name, :verification_name

    def to_json
      { 'credentials_name'     => credentials_name,
        'failing_resource_ids' => failing_resource_ids,
        'name'                 => name,
        'passing_resource_ids' => passing_resource_ids,
        'provider_name'        => provider_name,
        'resource_name'        => resource_name,
        'verification_name'    => verification_name }.to_json
    end

    def initialize(args)
      @credentials_name  = args[:credentials_name]
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

    def passing_resource_ids
      passing_resources.map{|r| r.id}
    end

    def failing_resource_ids
      failing_resources.map{|r| r.id}
    end

  end
end
