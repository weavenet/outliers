module Outliers
  class Result

    attr_reader :connection_name, :failing_resources, :name, :passing_resources,
                :provider_name, :resource_name, :verification

    def initialize(args)
      @connection_name   = args[:connection_name]
      @failing_resources = args[:failing_resources]
      @name              = args[:name]
      @passing_resources = args[:passing_resources]
      @provider_name     = args[:provider_name]
      @resource_name     = args[:resource_name]
      @verification      = args[:verification]
    end

    def to_s
      passed? ? 'passed' : 'failed'
    end

    def passed?
      !failed?
    end

    def failed?
      @failing_resources.any?
    end

  end
end
