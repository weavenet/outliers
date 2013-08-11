module Outliers
  module Providers
    module Aws
      class Sqs < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.info "Connecting to region '#{@region}'." unless @sqs
          @sqs ||= ::AWS::SQS.new config
        end

      end
    end
  end
end
