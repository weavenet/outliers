module Outliers
  module Filters
    module Aws
      module Tags

        def filter_tag(value)
          tag_name  = value.split(':').first
          tag_value = value.split(':').last
          logger.debug "Filtering by tag '#{tag_name}' equals '#{tag_value}'."
          all.select do |r|
            if r.tags.has_key? tag_name
              r.tags[tag_name] == tag_value
            else
              false
            end
          end
        end

        module_function

        def self.filters
          [
            { name: 'tag',
              description: 'Filter instances tagged with the given tag name and value.',
              args: 'TAG_NAME:VALUE"' }
          ]
        end 

      end
    end
  end
end
