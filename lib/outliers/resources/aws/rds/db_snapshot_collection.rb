module Outliers
  module Resources
    module Aws
      module Rds
        class DbSnapshotCollection < Collection

          def load_all
            connect.db_snapshots.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
