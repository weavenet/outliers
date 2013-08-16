module Outliers
  class Result

    attr_reader :evaluation, :failing_keys, :passing_keys, :resource, :verification

    def initialize(args)
      @evaluation   = args[:evaluation]
      @failing_keys = args[:failing_keys]
      @passing_keys = args[:passing_keys]
      @resource     = args[:resource]
      @verification = args[:verification]
    end

    def to_s
      passed? ? 'passed' : 'failed'
    end

    def passed?
      !failed?
    end

    def failed?
      @failing_keys.any?
    end

  end
end
