require 'outliers/resources/aws'
 
module Outliers
  module Resources
    module_function

    def list
      Outliers::Resources.collections
    end

    def collections
      all_the_modules.select {|m| (m.is_a? Class) && (m.to_s =~ /Collection$/)}
    end
  end
end
