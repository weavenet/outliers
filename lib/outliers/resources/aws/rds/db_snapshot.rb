module Outliers
  module Resources
    module Aws
      module Rds
        class DbSnapshot < Resource
          def self.key
            'db_snapshot_identifier'
          end
        end
      end
    end
  end
end
