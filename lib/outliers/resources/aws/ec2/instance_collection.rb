module Outliers
  module Resources
    module Aws
      module Ec2
        class InstanceCollection < Collection

          def load_all
            connect.instances.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
