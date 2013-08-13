module Outliers
  module Credentials
    module_function

    def load_from_file(file)
      credentials = {}
      contents = File.read file
      YAML.load(contents).each_pair do |k,v|
        credentials[k] = v
      end
      credentials
    end

  end
end
