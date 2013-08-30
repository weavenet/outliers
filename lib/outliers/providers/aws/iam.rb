module Outliers
  module Providers
    module Aws
      class Iam < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @iam
          @iam ||= ::AWS::IAM.new config
        end

      end
    end
  end
end
