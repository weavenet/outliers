require 'json'

module Outliers
  class Result

    attr_reader :credentials_name, :failing_resources, :name, :passing_resources,
                :provider_name, :resource_name, :verification_name

    def initialize(args)
      @credentials_name  = args[:credentials_name]
      @failing_resources = args[:failing_resources]
      @name              = args[:name]
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

  end
end
