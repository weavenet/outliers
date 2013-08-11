module Outliers
  module Resources
    module Aws
      module Sqs
        class QueueCollection < Collection

          def load_all
            connect.queues.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
