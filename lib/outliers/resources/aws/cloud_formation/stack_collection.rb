module Outliers
  module Resources
    module Aws
      module CloudFormation
        class StackCollection < Collection

          def load_all
            connect.stacks.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
