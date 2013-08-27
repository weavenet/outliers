module Outliers
  module Providers
    module Aws
      class Elb < Provider

        include Shared

        def self.credential_arguments
          Shared.credential_arguments
        end

        def connect
          logger.debug "Connecting to region '#{@region}'." unless @elb
          @elb ||= ::AWS::ELB.new config
        end

      end
    end
  end
end
