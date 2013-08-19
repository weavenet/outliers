module Outliers
  module Filters
    module Aws
      module Ec2
        module Tags

          def filter_tag(value)
            tag_name  = value.split(':').first
            tag_value = value.split(':').last
            logger.info "Filtering by tag '#{tag_name}' equals '#{tag_value}'."
            all.select do |r|
              if r.tags.has_key? tag_name
                value = r.tags[tag_name]
                result = value == tag_value
                logger.debug "'#{r.id}' has tag with value '#{value}'. #{result ? 'Matches' : 'Does not match'} filter."
                result
              else
                logger.debug "'#{r.id}' does not have tag '#{tag_name}'"
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
end
