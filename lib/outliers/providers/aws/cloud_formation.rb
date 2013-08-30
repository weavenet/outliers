module Outliers
  module Providers
    module Aws
      class CloudFormation < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @cf
          @cf ||= ::AWS::CloudFormation.new config
        end

      end
    end
  end
end
