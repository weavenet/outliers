module Outliers
  module Resources
    module Aws
      module Ec2
        class InstanceCollection < Collection

          include Outliers::Filters::Aws::Tags

          def load_all
            connect.instances.map {|r| resource_class.new r}
          end

          def self.filters
            Outliers::Filters::Aws::Tags.filters
          end 

        end
      end
    end
  end
end
