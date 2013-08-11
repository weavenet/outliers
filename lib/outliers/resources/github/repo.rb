module Outliers
  module Resources
    module Github
      class Repo < Resource
        def self.verifications
          [
            { name: 'private',
              description: 'Repo is private.' },
            { name: 'public',
              description: 'Repo is public.' }
          ]
        end

        def private?
          source.private
        end

        def public?
          !source.private
        end
      end
    end
  end
end
