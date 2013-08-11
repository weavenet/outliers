module Outliers
  module Resources
    module Aws
      module Ec2
        class Instance < Resource
          def self.key
            'instance_id'
          end

          def self.verifications
            [
              { name: 'classic',
                description: 'Instance is in AWS Classic (No VPC).' },
              { name: 'source_dest_check',
                description: 'Instance source dest check set to true.' },
              { name: 'running',
                description: 'Instance status is running.' },
              { name: 'valid_image_id',
                description: 'ami_ids=ami_id1,ami_id2 - Instances Image ID (AMI) is in given list.',
                args: 'image_ids: [IMAGE_ID1, IMAGEID2]' },
              { name: 'vpc',
                description: 'Instance is in a VPC.' }
            ]
          end

          def classic?
            !vpc?
          end

          def running?
            logger.debug "Verifying '#{status}' equals 'running'."
            status == :running
          end

          def source_dest_check?
            unless vpc?
              logger.debug "Instance must be in a VPC to validate source_dest_check. Returning false."
              return false
            end
            source_dest_check == true
          end

          def valid_image_id?(args)
            image_ids = Array(args[:image_ids])

            logger.debug "Verifying Image ID '#{image_id}' is one of '#{image_ids.join(', ')}'."
            image_ids.include? image_id
          end

          def vpc?
            !source.vpc_id.nil?
          end

          private

          def tags
            @tags ||= source.tags
          end

          def image_id
            @image_id ||= source.image_id
          end

          def instance_type
            @instance_type ||= source.instance_type
          end

          def source_dest_check
            @source_dest_check ||= source.source_dest_check
          end
        end
      end
    end
  end
end
