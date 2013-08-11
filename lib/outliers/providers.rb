require 'outliers/providers/aws'
require 'outliers/providers/github'

module Outliers
  module Providers
    module_function

    def all
      all_the_modules.select{|m| m.is_a? Class}
    end

    def name_map 
      r = {}
      all.each { |p| r.merge! p.to_human => p }
      r
    end
 
  end
end
