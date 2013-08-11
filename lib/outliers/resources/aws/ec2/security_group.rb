module Outliers
  module Resources
    module Aws
      module Ec2
        class SecurityGroup < Resource
          def self.verifications
            [
              { name: 'no_public_internet_ingress',
                description: 'Security Group has no rules open to "0.0.0.0/0".' }
            ]
          end

          def no_public_internet_ingress?
            logger.debug "Verifying '#{id}'."
            source.ip_permissions.select do |i|
              if !i.egress? && (i.ip_ranges.include? "0.0.0.0/0")
                logger.debug "Security Group '#{id}' is open to '#{i.ip_ranges.join(', ')}' via '#{i.protocol}'."
                false
              else
                true
              end
            end.any?
          end
        end
      end
    end
  end
end
