module Outliers
  module Credentials
    module_function

    # To Do - Remove me once validated not needed
    def load_from_config_folder
      credentials = {}
      files = Dir.entries(File.join(Outliers.config_path, 'credentials')) - ['.', '..']
      files.each do |file|
        contents = File.read File.join(Outliers.config_path, 'credentials', file)
        YAML.load(contents).each_pair do |k,v|
          credentials[k] = v
        end
      end
      credentials
    end

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
