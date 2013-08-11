module Outliers
  module Resources
    module Aws
      module Sqs
        class Queue < Resource
          def self.key
            'url'
          end
        end
      end
    end
  end
end
