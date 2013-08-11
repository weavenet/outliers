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

        module_function

        def credential_arguments
          {
            'access_key_id'     => 'AWS Account Access Key',
            'secret_access_key' => 'AWS Account Secret Key',
            'region'            => 'AWS Region (Default us-east-1)'
          }
        end

      end
    end
  end
end
