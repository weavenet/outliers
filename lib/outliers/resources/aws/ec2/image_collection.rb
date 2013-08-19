module Outliers
  module Resources
    module Aws
      module Ec2
        class ImageCollection < Collection

          include Outliers::Filters::Aws::Ec2::Tags

          def load_all
            logger.debug "Loading private images owned by this account."
            connect.images.with_owner(:self).map {|r| resource_class.new r}
          end

          def self.filters
            Outliers::Filters::Aws::Ec2::Tags.filters
          end 

        end
      end
    end
  end
end
