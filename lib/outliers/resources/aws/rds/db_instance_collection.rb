module Outliers
  module Resources
    module Aws
      module Rds
        class DbInstanceCollection < Collection

          def load_all
            connect.db_instances.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
