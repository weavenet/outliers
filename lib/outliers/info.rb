require 'yaml'

module Outliers
  module Info
    module_function

    def reference
      YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), '../../reference.yaml')))
    end

  end
end
