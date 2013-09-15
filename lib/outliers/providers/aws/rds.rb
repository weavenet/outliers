module Outliers
  module Providers
    module Aws
      class Rds < Provider

        include Shared

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @rds
          @rds ||= ::AWS::RDS.new config
        end

      end
    end
  end
end
