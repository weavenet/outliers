module Outliers
  module Resources
    module Aws
      module Ec2
        class Image < Resource
          def self.key
            'image_id'
          end
        end
      end
    end
  end
end
