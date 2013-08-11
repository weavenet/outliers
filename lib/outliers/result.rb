module Outliers
  class Result

    attr_reader :description, :passed

    def initialize(args)
      @description = args[:description]
      @passed      = args[:passed]
    end

    def to_s
      passed? ? 'passed' : 'failed'
    end

    def passed?
      @passed == true
    end

    def failed?
      !passed?
    end

  end
end
