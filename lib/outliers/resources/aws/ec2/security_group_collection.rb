module Outliers
  module Resources
    module Aws
      module Ec2
        class SecurityGroupCollection < Collection

          def load_all
            connect.security_groups.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
