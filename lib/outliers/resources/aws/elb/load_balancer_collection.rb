module Outliers
  module Resources
    module Aws
      module Elb
        class LoadBalancerCollection < Collection

          def load_all
            connect.load_balancers.map {|r| resource_class.new r}
          end

        end
      end
    end
  end
end
