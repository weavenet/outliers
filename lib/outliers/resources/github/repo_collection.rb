module Outliers
  module Resources
    module Github
      class RepoCollection < Collection

        def load_all
          connect.repos.list(:type => 'all').map {|r| resource_class.new r}
        end

      end
    end
  end
end
