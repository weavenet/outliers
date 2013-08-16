module Outliers
  class VerificationResponse

    attr_reader :failing_keys, :passing_keys

    def initialize(args)
      @failing_keys = args[:failing_keys]
      @passing_keys = args[:passing_keys]
    end

  end
end
