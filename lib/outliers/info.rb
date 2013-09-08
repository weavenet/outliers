require 'yaml'

module Outliers
  module Info
    module_function

    def verifications
      YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), '../../verifications.yaml')))
    end
  end
end
