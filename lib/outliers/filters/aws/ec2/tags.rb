module Outliers
  module Filters
    module Aws
      module Ec2
        module Tags

          def filter_tag(value)
            tag_name  = value.split(':').first
            tag_value = value.split(':').last
            logger.info "Filtering by tag '#{tag_name}' equals '#{tag_value}'."
            list.select do |r|
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

        end
      end
    end
  end
end
