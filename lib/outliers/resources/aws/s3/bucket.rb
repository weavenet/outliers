module Outliers
  module Resources
    module Aws
      module S3
        class Bucket < Resource

          def empty?
            logger.debug "Bucket #{id} has #{count} objects."

            count == 0
          end

          def no_public_objects?
            passed = true
            
            logger.info "Validating #{objects.count} objects in '#{id}' are private."

            objects.each do |o|
              logger.debug "Verifying '#{o.key}' is private."
              o.acl.grants.select do |g|
                grantee = Nokogiri::XML(g.grantee.to_s).children.children.children.to_s
                if grantee == "http://acs.amazonaws.com/groups/global/AllUsers" || grantee == "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
                  logger.debug "Object '#{o.key}' in '#{id}' has public grant '#{grantee}'."
                  passed = false
                end
              end
            end

            logger.debug "Verification of '#{id}' #{passed ? 'passed' : 'failed'}."

            passed
          end

          def not_configured_as_website?
            !configured_as_website?
          end

          def configured_as_website?
            !website_configuration.nil?
          end

          private

          def website_configuration
            source.website_configuration
          end

          def count
            objects.count
          end

          def objects
            @objects ||= source.objects
          end

        end
      end
    end
  end
end
