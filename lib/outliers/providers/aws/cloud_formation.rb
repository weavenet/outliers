module Outliers
  module Providers
    module Aws
      class CloudFormation < Provider

        include Shared

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @cf
          @cf ||= ::AWS::CloudFormation.new config
        end

      end
    end
  end
end
