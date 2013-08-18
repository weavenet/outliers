module Outliers
  class Result

    attr_reader :evaluation, :failing_resources, :passing_resources, :resource, :verification

    def initialize(args)
      @evaluation        = args[:evaluation]
      @failing_resources = args[:failing_resources]
      @passing_resources = args[:passing_resources]
      @resource          = args[:resource]
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
