module Outliers
  module Providers
    module Aws
      class Sqs < Provider

        include Shared

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @sqs
          @sqs ||= ::AWS::SQS.new config
        end

      end
    end
  end
end
