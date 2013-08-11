require 'outliers/resources/aws'
require 'outliers/resources/github'
 
module Outliers
  module Resources
    module_function

    def collections
      all_the_modules.select {|m| (m.is_a? Class) && (m.to_s =~ /Collection$/)}
    end
  end
end
