module Outliers
  module Providers
    module Aws
      class S3 < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @iam
          @iam ||= ::AWS::S3.new config
        end

      end
    end
  end
end
