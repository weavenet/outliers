module Outliers
  module Resources
    module Aws
      module S3
        class BucketCollection < Collection

          def load_all
            unless provider.credentials['region'] == 'us-east-1'
              raise Exceptions::UnsupportedRegion.new "Bucket verifications must target region us-east-1."
            end
            connect.buckets.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
