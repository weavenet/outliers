module Outliers
  module Resources
    module Aws
      module Ec2
        class InstanceCollection < Collection

          def load_all
            connect.instances.map {|r| resource_class.new r}
          end

          def self.filters
            [
              { name: 'tag',
                description: 'Filter instances tagged with the given tag name and value.',
                args: 'TAG_NAME:VALUE"' }
            ]
          end 

          def filter_tag(value)
            tag_name  = value.split(':').first
            tag_value = value.split(':').last
            logger.debug "Filtering by tag '#{tag_name}' = '#{tag_value}'."
            all.select do |r|
              return false unless r.tags.has_key? tag_name
              r.tags[tag_name] == tag_value
            end
          end

        end
      end
    end
  end
end
