require "aws-sdk"

module Outliers
  module Providers
    module Aws
      module Shared

        def settings(args)
          @access_key_id     = args.fetch :access_key_id
          @secret_access_key = args.fetch :secret_access_key
          @region            = args.fetch :region, 'us-east-1'
        end

        def config
          { :access_key_id     => @access_key_id,
            :secret_access_key => @secret_access_key,
            :region            => @region }
        end

      end
    end
  end
end
