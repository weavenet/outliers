module Outliers
  module Account
    module_function

    def load_from_file(file)
      account = {}
      contents = File.read file
      YAML.load(contents).each_pair do |k,v|
        account[k] = v
      end
      account
    end

  end
end
