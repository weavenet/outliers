module Outliers
  module Resources
    module Aws
      module Iam
        class UserCollection < Collection

          def load_all
            connect.users.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
