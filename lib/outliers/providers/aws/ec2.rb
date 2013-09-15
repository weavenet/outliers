module Outliers
  module Providers
    module Aws
      class Ec2 < Provider

        include Shared

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @ec2
          @ec2 ||= ::AWS::EC2.new config
        end

      end
    end
  end
end
