require 'outliers/resources/aws'
 
module Outliers
  module Resources
    module_function

    def find_by_name(name)
      l = resources.select {|m| m.to_human == name }
      l.any? ? l.first : nil
    end

    def collections
      all_the_modules.select {|m| (m.is_a? Class) && (m.to_s =~ /Collection$/)}
    end

    def resources
      all_the_modules.select {|m| (m.is_a? Class) && !(m.to_s =~ /Collection$/)}
    end
  end
end
