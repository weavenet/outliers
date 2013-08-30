module Outliers
  module Providers
    module Aws
      class Rds < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @rds
          @rds ||= ::AWS::RDS.new config
        end

      end
    end
  end
end
